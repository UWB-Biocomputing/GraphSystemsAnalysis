"""
@file     MLPregression.py 
@author   Jewel Lee (jewel87@uw.edu)
@date     2/19/2018

@brief    Perform GridSearch and 10-fold CV on MLPRegressor

"""
import time
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn import metrics
from sklearn.metrics import explained_variance_score, r2_score
from sklearn.neural_network import MLPRegressor
from sklearn.model_selection import GridSearchCV
# -----------------------------------------------------------------------------
# STEP 0: Load data
# -----------------------------------------------------------------------------
data_file = 'tR_1.0--fE_0.90_10000/MLdata/preBurst100.csv'
label_file = 'tR_1.0--fE_0.90_10000/MLdata/allBurstOriginXY.csv'
# data_file = 'preBurst100.csv'
# label_file = 'allBurstOriginXY.csv'
X = np.loadtxt(open(data_file, "rb"), delimiter=",", dtype=np.int16)
y = np.loadtxt(open(label_file, "rb"), delimiter=",", dtype=np.int16)
# -----------------------------------------------------------------------------
# STEP 1: split data into training and test dataset
# -----------------------------------------------------------------------------
X = X[0:150, :]                     # use only first 150 bursts
y = y[0:150]
n_samples = X.shape[0]
n_features = X.shape[1]
assert (y.shape[0] == n_samples), "ERROR: number of samples and label don't match"
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=1)

# -----------------------------------------------------------------------------
# STEP 2: Hyper-parameter tuning using grid search (+ k-fold cross validation)
# -----------------------------------------------------------------------------
#'learning_rate': ["constant", "invscaling", "adaptive"]
# 'activation': ["logistic","tanh", "relu"],
#'hidden_layer_sizes': [20, 100, 200, 500, (20, 20), (100, 100), (200, 200), (500, 500),
#                       (20, 20, 20), (100, 100, 100), (200, 200, 200), (500, 500, 500), (700, 700, 700)],
parameters = {
    'learning_rate': ["constant"],
    'hidden_layer_sizes': [20, 100, 200, 500, 1000, (20, 20), (100, 100), (200, 200), (500, 500), (1000, 1000),
                           (20, 20, 20), (100, 100, 100), (200, 200, 200), (500, 500, 500), (1000, 1000, 1000)],
    'activation': ["relu"],
    'solver': ["adam"],
    'max_iter': [200, 500, 1000],
    'batch_size': [10, 50, 100, 150],
}

model = MLPRegressor()
gs = GridSearchCV(estimator=model, param_grid=parameters,
                  verbose=2, cv=10)
gs.fit(X, y)

print("Best score:", gs.best_score_)
print("Best hyper-parameters:")
best_parameters = gs.best_estimator_.get_params()
for param_name in sorted(parameters.keys()):
    print("\t%s: %r" % (param_name, best_parameters[param_name]))

# -----------------------------------------------------------------------------
# STEP 3: Make prediction with the best hyper-parameters
# -----------------------------------------------------------------------------
print(' ')
print('## MLP Regression Results ##')
mlp = MLPRegressor(learning_rate=gs.best_estimator_.learning_rate,
                   hidden_layer_sizes=gs.best_estimator_.hidden_layer_sizes,
                   activation=gs.best_estimator_.activation,
                   solver=gs.best_estimator_.solver,
                   max_iter=gs.best_estimator_.max_iter,
                   batch_size=gs.best_estimator_.batch_size)
t = time.time()
mlp.fit(X_train, y_train)
t_mlp = time.time() - t
y_pred_mlp = mlp.predict(X_test)
# -----------------------------------------------------------------------------
# STEP 4: Output Model Performance
# -----------------------------------------------------------------------------
print('R2:    ', mlp.score(X_test, y_pred_mlp))
print('R2:    ', r2_score(y_test, y_pred_mlp))
print('MAE:   ', metrics.mean_absolute_error(y_test, y_pred_mlp))
print('MSE:   ', metrics.mean_squared_error(y_test, y_pred_mlp))
print('RMSE:  ', np.sqrt(np.absolute(metrics.mean_squared_error(y_test, y_pred_mlp))))
print('variance score: ', explained_variance_score(y_test, y_pred_mlp, multioutput='uniform_average'))
print('training time:   ', t_mlp)
