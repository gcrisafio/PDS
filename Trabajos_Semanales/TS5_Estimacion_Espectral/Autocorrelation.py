import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import csv

sns.set()

class Autocorrelation():

    def __init__(self):
        self.x = None
        self.N = None
        self.r_xx = None

    def estimate(self, x, f=None, M=10):
        '''
            Estimates P_xx for the given signal sequence x.

            Args:
                x (numpy array of doubles): Signal
                f (numpy array of doubles in range [0, 0.5]): Frequence
                M (integer): Window is defined as a triangle in the interval [-M, M]
        '''
        # Initialize values.
        if f is None:
            self.f = self.default_f
        else:
            self.f = f
        self.x = x
        self.M = M
        self.N = len(self.x)
        P_temp = []  # Lista temporal para almacenar los valores calculados.

        # Initialize window and estimate autocerr. function.
        w = TriangWindow(M)
        self.r_xx.estimate(x)

        # Calculate P.
        for i in range(len(self.f)):
            sum = 0
            for n in np.arange(-self.N + 1, self.N):
                sum += w[n] * self.r_xx[n] * cmath.exp(-1j * 2 * cmath.pi * self.f[i] * n)
            P_temp.append(sum.real)

        self.P = np.array(P_temp)  # Convierte la lista en un arreglo numpy al final del cálculo.


    def plot(self):
        '''
            Plots estimated r_xx.
        '''
        # Check if anything is estimated.
        if self.r_xx is None:
            return
        r_xx_plot = self._double_side_r_xx()

        plt.figure()
        plt.plot(np.arange(-len(r_xx_plot)//2 + 1, len(r_xx_plot)//2 + 1), r_xx_plot)
        plt.title('Autocorrelation function estimation')
        plt.xlabel('n')
        plt.ylabel('r_xx')
        plt.show()

    def compare(self, x=None):
        '''
            Compares with numpy functon 'correlate'.

            Args:
                x (numpy array of doubles): Signal
        ''' 
        r_xx_np = np.correlate(x, x, mode='full')           
        self.estimate(x)
        r_xx_plot = self._double_side_r_xx()

        # Plot them together.
        plt.figure()
        plt.plot(np.arange(-len(r_xx_plot)//2 + 1, len(r_xx_plot)//2 + 1), r_xx_plot,
            'b', label='autocorrelation')
        plt.plot(np.arange(-len(r_xx_np)//2 + 1, len(r_xx_np)//2 + 1), r_xx_np,
            'r--', label='numpy')
        plt.legend()
        plt.title('Autocorrelation function comparation')
        plt.xlabel('n')
        plt.ylabel('r_xx')
        plt.show()

    def _double_side_r_xx(self):
        r_xx_rev = self.r_xx[::-1]
        return np.append(r_xx_rev[:-1], self.r_xx)

    def __getitem__(self, key):
        '''
            Returns r_xx[key].
        '''
        if self.r_xx is None:
            return None

        if abs(key) >= self.N:
            return 0
        if key >= 0:
            return self.r_xx[key]
        else:
            return np.conjugate(self.r_xx[-key])