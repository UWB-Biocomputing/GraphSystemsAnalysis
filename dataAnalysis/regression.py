"""
@file     regression.py 
@author   Jewel Lee (jewel87@uw.edu)
@date     2/19/2018

@brief    Perform Linear, Ridge, Lasso, MLP regression

"""
import time
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn import metrics
from sklearn.linear_model import LinearRegression
from sklearn.linear_model import MultiTaskLassoCV, RidgeCV
from sklearn.metrics import explained_variance_score, r2_score
from sklearn.neural_network import MLPRegressor
# from sklearn.linear_model import LogisticRegression
# from sklearn.linear_model import SGDRegressor
# from sklearn.linear_model import LassoCV, RidgeCV

# -----------------------------------------------------------------------------
# Load data and split data into training and test data sets
# -----------------------------------------------------------------------------
# data_file = '/Users/jewellee/Documents/MATLAB/BrainGrid/data/nonBurstData.csv'
# label_file = '/Users/jewellee/PycharmProjects/ML/project/data/allBurstOriginXY.csv'
data_file = 'tR_1.0--fE_0.90_10000/MLdata/preBurst100.csv'
label_file = 'tR_1.0--fE_0.90_10000/MLdata/allBurstOriginXY.csv'
# data_file = 'preBurst100.csv'
# label_file = 'allBurstOriginXY.csv'
X = np.loadtxt(open(data_file, "rb"), delimiter=",", dtype=np.int16)
y = np.loadtxt(open(label_file, "rb"), delimiter=",", dtype=np.int16)
# y = y.reshape(-1,1)
X = X[0:150, :]
y = y[0:150]
n_samples = X.shape[0]
n_features = X.shape[1]
assert (y.shape[0] == n_samples), "ERROR: number of samples and label don't match"
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=1)

# -----------------------------------------------------------------------------
# Method 1: Linear regression
# -----------------------------------------------------------------------------
print(' ')
print('## 1. Linear Regression Results ##')
linreg = LinearRegression()
t = time.time()
linreg.fit(X_train, y_train)
t_linear = time.time() - t
y_pred_linreg = linreg.predict(X_test)
print('R2:    ', r2_score(y_test, y_pred_linreg))
print('MAE:   ', metrics.mean_absolute_error(y_test, y_pred_linreg))
print('MSE:   ', metrics.mean_squared_error(y_test, y_pred_linreg))
print('RMSE:  ', np.sqrt(np.absolute(metrics.mean_squared_error(y_test, y_pred_linreg))))
print('variance score:', explained_variance_score(y_test, y_pred_linreg, multioutput='uniform_average'))
print('training time:   ', t_linear)
# -----------------------------------------------------------------------------
# Method 2: Logistic regression
# -----------------------------------------------------------------------------
# print(' ')
# print('## Logistic Regression Results ##')
# logreg = LogisticRegression(penalty='l2')
# logreg.fit(X_train, y_train)
# y_pred_logreg = logreg.predict(X_test)
# print('R2:    ', r2_score(y_test, y_pred_logreg))
# print('MAE:   ', metrics.mean_absolute_error(y_test, y_pred_logreg))
# print('MSE:   ', metrics.mean_squared_error(y_test, y_pred_logreg))
# print('RMSE:  ', np.sqrt(np.absolute(metrics.mean_squared_error(y_test, y_pred_logreg))))
# print('variance score:', explained_variance_score(y_test, y_pred_logreg, multioutput='uniform_average'))

# -----------------------------------------------------------------------------
# Method 3: MultiTaskLassoCV regression with 10-fold CV
# -----------------------------------------------------------------------------
print(' ')
print('## 2. Lasso Regression Results ##')
lasso = MultiTaskLassoCV(cv=10, eps= 0.01, max_iter=1000)
t = time.time()
lasso.fit(X_train, y_train)
t_lasso = time.time() - t
y_pred_lasso = lasso.predict(X_test)
print('R2:    ', r2_score(y_test, y_pred_lasso))
print('MAE:   ', metrics.mean_absolute_error(y_test, y_pred_lasso))
print('MSE:   ', metrics.mean_squared_error(y_test, y_pred_lasso))
print('RMSE:  ', np.sqrt(np.absolute(metrics.mean_squared_error(y_test, y_pred_lasso))))
print('variance score: ', explained_variance_score(y_test, y_pred_lasso, multioutput='uniform_average'))
print('training time:   ', t_lasso)
#
# # -----------------------------------------------------------------------------
# # Method 4: Ridge regression with 10-fold CV
# # -----------------------------------------------------------------------------
print(' ')
print('## 3. Ridge Regression Results ##')
ridge = RidgeCV(cv=10, alphas=(0.1, 0.3, 0.5, 0.7, 1.0))
t = time.time()
ridge.fit(X_train, y_train)
t_ridge = time.time() - t
print(ridge.alpha_)
y_pred_ridge = ridge.predict(X_test)
print('R2:    ', r2_score(y_test, y_pred_ridge))
print('MAE:   ', metrics.mean_absolute_error(y_test, y_pred_ridge))
print('MSE:   ', metrics.mean_squared_error(y_test, y_pred_ridge))
print('RMSE:  ', np.sqrt(np.absolute(metrics.mean_squared_error(y_test, y_pred_ridge))))
print('variance score: ', explained_variance_score(y_test, y_pred_ridge, multioutput='uniform_average'))
print('training time:   ', t_ridge)
#
# # -----------------------------------------------------------------------------
# # Method 5: MLP Regression
# # -----------------------------------------------------------------------------
print(' ')
print('## 4. MLP Regression Results ##')
mlp = MLPRegressor(activation='relu', alpha=0.001, max_iter=200,
                   hidden_layer_sizes=(1000, 1000), learning_rate='constant',
                   batch_size=50, random_state=100,
                   solver='adam', validation_fraction=0.1, verbose=False)
t = time.time()
mlp.fit(X_train, y_train)
t_mlp = time.time() - t
y_pred_mlp = mlp.predict(X_test)
print('R2:    ', r2_score(y_test, y_pred_mlp))
print('MAE:   ', metrics.mean_absolute_error(y_test, y_pred_mlp))
print('MSE:   ', metrics.mean_squared_error(y_test, y_pred_mlp))
print('RMSE:  ', np.sqrt(np.absolute(metrics.mean_squared_error(y_test, y_pred_mlp))))
print('variance score: ', explained_variance_score(y_test, y_pred_mlp, multioutput='uniform_average'))
print('training time:   ', t_mlp)

# np.savetxt("y_test.csv", y_test, delimiter=",")
# # np.savetxt("y_pred_logreg.csv", y_pred_logreg.astype(int), delimiter=",")
# np.savetxt("y_pred_linreg.csv", y_pred_linreg.astype(int), delimiter=",")
# np.savetxt("y_pred_lasso.csv", y_pred_lasso.astype(int), delimiter=",")
# np.savetxt("y_pred_ridge.csv", y_pred_ridge.astype(int), delimiter=",")
# np.savetxt("y_pred_mlp.csv", y_pred_mlp.astype(int), delimiter=",")

# print(y_pred_logreg.astype(int))
# print(y_pred_linreg.astype(int))
# print(y_pred_lasso.astype(int))
# print(y_pred_ridge.astype(int))
# print(y_pred_mlp.astype(int))