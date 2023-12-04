#!/usr/bin/env python
# coding: utf-8

# # Identification of Potential Fish Zones

# In[8]:


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sbn
get_ipython().run_line_magic('matplotlib', 'notebook')
np.random.seed(40)


# In[9]:


file_path = r'C:\Users\Isaac\Downloads\sample_nan.csv'
td = pd.read_csv(file_path)
print (td)


# In[10]:


'''
Sea Surface Temperature, Chlorophyll, 
Relative Humidity, Sea Level Pressure, Air Temperature, Total Cloudiness and Total Fish catch data.

'''


# # Remove Year and Month and Label

# In[11]:


df =  td[['SST', 'SSC', 'AT', 'RH', 'SLP', 'TC', 'TOTALOIL']]
df


# # Shuffle  (randomly permute) the dataset (on rows) and apply interpolate method (on columns )

# In[58]:


df = df.sample(frac=1).reset_index(drop=True)


# In[13]:


nedf = df.interpolate(method='cubic', axis=0).ffill().bfill()


# In[14]:


nedf = nedf.astype("float")
nedf


# # Create label

# In[15]:


ssc = np.array(nedf['SSC'])
sst = np.array(nedf['SST'])
fc = np.array(nedf['TOTALOIL'])


# In[16]:


lab = []
for i in range(len(ssc)):
    if ssc[i]>0.2 and sst[i]>25.0 and fc[i]>10000:
        lab.append("PFZ")
    else:
        lab.append("NPFZ")


# In[17]:


label = pd.DataFrame(lab,columns=['label'])


# In[18]:


dataset = pd.concat([nedf,label],axis=1)
dataset


# In[19]:


dataset.to_csv("cubic_interpolation.csv",sep='\t', encoding='utf-8')


# In[20]:


# create a copy
df1 = dataset


# In[21]:


# mapping
df1['label']=df1['label'].map({'PFZ':0,'NPFZ':1})


# # Drop Total Catch

# In[22]:


df2=df1.drop(['TOTALOIL'],axis=1)
df2.columns


# # Split data and label

# In[23]:


X = df2[['SST', 'SSC', 'AT', 'RH', 'SLP', 'TC']]
Y = df2[['label']]


# # Normalized the data and label

# In[24]:


from sklearn import preprocessing


# In[25]:


X_norm = preprocessing.normalize(X, norm='l2')


# In[26]:


y = np.squeeze(np.array(Y).reshape(1,-1))


# # Feature importance

# In[27]:


from sklearn.ensemble import ExtraTreesClassifier


# In[28]:


model = ExtraTreesClassifier()
model.fit(X_norm,y)
feature_importance=model.feature_importances_
print(model.feature_importances_)


# In[29]:


feature_importance = 100.0 * (feature_importance / feature_importance.max())
sorted_idx = np.argsort(feature_importance)
pos = np.arange(sorted_idx.shape[0]) + .8
plt.barh(pos, feature_importance[sorted_idx], align='center')
plt.yticks(pos, X.columns[sorted_idx])
plt.xlabel('Relative Importance')
plt.title('Variable Importance')
plt.show()


# # Applying Machine Learning Models

# In[30]:


from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X_norm,y, test_size=0.33, random_state=40)


# # SVM

# In[31]:


from sklearn import svm


# In[32]:


clf = svm.SVC() # svm classifer


# In[33]:


clf.fit(X_train, y_train)


# In[34]:


from sklearn.metrics import accuracy_score
from sklearn.metrics import confusion_matrix 
from sklearn.metrics import precision_recall_curve


# In[35]:


result1 = clf.predict(X_test)


# In[36]:


result1 = clf.predict(X_test)


# In[37]:


confusion_matrix(y_test,result1)


# In[38]:


print(accuracy_score(result1,y_test))


# # Boosted Tree

# In[39]:


pip install xgboost


# In[40]:


import xgboost as xgb


# In[41]:


model_xgboost = xgb.XGBClassifier() # boosted tree classifire
model_xgboost.fit(X_train,y_train)


# In[42]:


predXGB = model_xgboost.predict(X_test)
print(accuracy_score(predXGB,y_test))


# In[43]:


confusion_matrix(y_test,predXGB)


# In[44]:


test_set = pd.DataFrame(X_test,columns=['SST', 'SSC', 'AT', 'RH', 'SLP', 'TC'])
prediction = pd.DataFrame(predXGB,columns=['label'])
prediction['label'] = prediction['label'].map({0:'NPFZ',1:'PFZ'})
output = pd.concat([test_set,prediction],axis=1)
output.to_csv("output.csv",sep='\t', encoding='utf-8')


# # Decision Tree

# In[45]:


from sklearn import tree


# In[46]:


clfD = tree.DecisionTreeClassifier()


# In[47]:


clfD.fit(X_train,y_train)


# In[48]:


result2 = clfD.predict(X_test)


# In[49]:


accuracy_score(y_test,result2)


# In[50]:


confusion_matrix(y_test,result2)


# # Naive Bayes

# In[51]:


from sklearn.naive_bayes import GaussianNB


# In[52]:


gnb = GaussianNB()
gnb = gnb.fit(X_train, y_train)
pred = gnb.predict(X_test)
print(accuracy_score(pred,y_test))


# In[53]:


confusion_matrix(y_test,pred)


# # Random Forest

# In[54]:


from sklearn.ensemble import RandomForestClassifier


# In[55]:


clfRF = RandomForestClassifier(random_state=0)
clfRF.fit(X_train, y_train)
predRF = clfRF.predict(X_test)


# In[56]:


print(accuracy_score(predRF,y_test))


# In[57]:


confusion_matrix(y_test,predRF)


# In[ ]:




