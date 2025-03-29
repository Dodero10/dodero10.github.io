# Customer Churn Prediction Model

![Churn Prediction Dashboard](../../assets/images/churn-dashboard.jpg)

## Project Overview

A machine learning model designed to predict customer churn for a subscription-based SaaS company. The system identifies customers at high risk of cancellation, analyzes factors contributing to churn, and recommends retention strategies to reduce customer attrition.

### Business Problem

The company was experiencing a monthly churn rate of 4.5%, significantly affecting revenue and growth. With customer acquisition costs rising, retaining existing customers became a critical business priority.

### Key Features

- **Churn Prediction**: Identifies customers likely to cancel with 83% accuracy
- **Risk Scoring**: Assigns risk scores (1-100) to all customers
- **Key Indicators**: Highlights the most influential factors for each at-risk customer
- **Automated Alerts**: Notifies customer success teams about high-risk accounts
- **Segment Analysis**: Identifies customer segments with highest churn rates
- **What-If Analysis**: Simulates how changes to product or pricing might affect churn
- **ROI Calculator**: Estimates financial impact of retention strategies
- **Integration**: Connects with CRM and customer success platforms

## Technology Stack

### Data Processing & Analysis
- **Python**: Primary programming language
- **pandas**: Data manipulation and analysis
- **NumPy**: Numerical computing
- **scikit-learn**: Machine learning algorithms
- **XGBoost**: Gradient boosting implementation
- **SHAP**: Model explainability

### Data Storage
- **PostgreSQL**: Primary database
- **Amazon S3**: Data lake storage
- **dbt**: Data transformation

### Deployment & Monitoring
- **Docker**: Containerization
- **AWS SageMaker**: Model deployment
- **Airflow**: Workflow orchestration
- **MLflow**: Model tracking and versioning

### Visualization
- **Tableau**: Business intelligence dashboard
- **Plotly**: Interactive visualizations
- **Streamlit**: Internal tools and exploratory analysis

## Data Sources and Feature Engineering

### Data Sources

The model uses data from multiple sources:

1. **Product Usage Data**: Feature usage, session frequency, session duration, etc.
2. **Customer Information**: Industry, company size, contract terms, etc.
3. **Support Interactions**: Ticket volume, resolution time, satisfaction scores
4. **Billing History**: Payment issues, plan changes, add-ons
5. **Marketing Engagement**: Email opens, webinar attendance, content downloads

### Feature Engineering

Key engineered features that improved model performance:

- **Engagement Decline**: Rate of decrease in product usage over time
- **Feature Adoption Ratio**: Percentage of available features actively used
- **Support Sentiment Score**: NLP-based sentiment analysis of support tickets
- **Time Since Last Activity**: Days since the customer last used key features
- **Contract Lifecycle Stage**: Normalized time position within contract period

```python
# Example of feature engineering for engagement decline
def calculate_engagement_decline(usage_data):
    """
    Calculate the slope of engagement over the past 90 days
    Negative values indicate declining engagement
    """
    # Group by week and calculate average daily usage
    weekly_usage = usage_data.resample('W', on='date')['session_minutes'].mean()
    
    # Require at least 6 weeks of data
    if len(weekly_usage) < 6:
        return 0
    
    # Calculate slope using linear regression
    x = np.array(range(len(weekly_usage)))
    y = weekly_usage.values
    slope, _, _, _, _ = stats.linregress(x, y)
    
    # Normalize by the average usage
    avg_usage = weekly_usage.mean()
    if avg_usage > 0:
        normalized_slope = slope / avg_usage
    else:
        normalized_slope = 0
        
    return normalized_slope
```

## Model Development

### Approach

After experimenting with multiple algorithms, a stacked ensemble approach provided the best performance:

1. **Base Models**:
   - Gradient Boosting Classifier (XGBoost)
   - Random Forest Classifier
   - Logistic Regression with L1 regularization

2. **Meta-learner**:
   - Logistic Regression

### Training Process

- 70% of data used for training
- 15% for validation (hyperparameter tuning)
- 15% for testing (final evaluation)
- 5-fold cross-validation during development
- Historical data from Jan 2021 to Dec 2022
- Class imbalance addressed with SMOTE and class weighting

### Evaluation Metrics

| Metric | Score |
|--------|-------|
| Accuracy | 83.2% |
| Precision | 76.5% |
| Recall | 81.7% |
| F1 Score | 79.0% |
| AUC-ROC | 0.88 |

We prioritized recall over precision to minimize false negatives (missed churn predictions), as the cost of a false negative (lost customer) exceeds the cost of a false positive (unnecessary retention effort).

### Feature Importance

The top predictors of churn, in order of importance:

1. **Engagement trend (90 days)**: Declining usage pattern
2. **Support ticket sentiment**: Negative sentiment in recent tickets
3. **Feature adoption ratio**: Low adoption of key features
4. **Days since last login**: Extended periods of inactivity
5. **Contract renewal proximity**: Approaching contract end date

![Feature Importance Chart](../../assets/images/feature-importance.jpg)

## Model Explainability

We implemented SHAP (SHapley Additive exPlanations) to provide transparent, interpretable predictions:

```python
# Generate SHAP values for model explanations
def generate_customer_explanation(customer_id, features):
    """Create personalized explanation for a customer's churn prediction"""
    
    # Get model and explainer
    model = load_model('churn_ensemble_v3')
    explainer = shap.TreeExplainer(model)
    
    # Get customer data
    customer_data = features[features['customer_id'] == customer_id]
    if len(customer_data) == 0:
        return None
    
    # Remove ID column for prediction
    X = customer_data.drop(['customer_id', 'churned'], axis=1)
    
    # Calculate SHAP values
    shap_values = explainer.shap_values(X)
    
    # Generate explanation
    base_value = explainer.expected_value
    customer_prediction = model.predict_proba(X)[0, 1]
    
    # Get top factors
    feature_names = X.columns
    shap_df = pd.DataFrame({
        'feature': feature_names,
        'shap_value': shap_values[0]
    })
    
    # Sort by absolute value to get most influential features
    top_factors = shap_df.iloc[np.argsort(np.abs(shap_df['shap_value']))[-5:][::-1]]
    
    # Generate natural language explanation
    explanation = {
        'customer_id': customer_id,
        'churn_probability': float(customer_prediction),
        'risk_level': assign_risk_level(customer_prediction),
        'base_value': float(base_value),
        'top_factors': top_factors.to_dict(orient='records'),
        'recommended_actions': generate_recommendations(top_factors, customer_data)
    }
    
    return explanation
```

Each prediction includes:
- Overall churn probability
- Top 5 factors increasing/decreasing churn risk
- Specific values for those factors
- Comparison to typical values
- Tailored retention recommendations

## Deployment and Integration

### Real-time Prediction API

The model is deployed as a REST API using Flask and AWS SageMaker, integrated with:

1. **CRM System**: Displays risk scores on customer profiles
2. **Customer Success Platform**: Triggers workflows for at-risk customers
3. **Internal Dashboard**: Provides company-wide churn monitoring

### Batch Prediction Pipeline

A weekly batch process scores all customers and identifies newly at-risk accounts:

1. Data extraction from data warehouse
2. Feature generation and preprocessing
3. Batch prediction using the ensemble model
4. Results loaded into the application database
5. Alerts generated for customers crossing risk thresholds
6. Weekly summary reports for management

## Results and Impact

After six months in production, the model has delivered significant business value:

- **Churn reduction**: Monthly churn decreased from 4.5% to 3.2%
- **Revenue impact**: $1.2M in preserved annual recurring revenue
- **ROI**: 8.5x return on the project investment
- **Efficiency**: Customer success team can now focus on the 20% of customers who represent 80% of churn risk
- **Insights**: Identified two previously unknown causes of churn that led to product improvements

### Case Study: Enterprise Segment

The most dramatic results came from the enterprise customer segment:
- Previously had 3.8% monthly churn
- Now reduced to 1.9% monthly churn
- Retention efforts focused on account expansion and executive engagement
- Average contract value increased by 15% for retained at-risk accounts

## Lessons Learned

1. **Behavioral signals outperform demographic data**: How customers use the product is more predictive than who they are.

2. **Early warning is critical**: The model now identifies churn risk 60-90 days before cancellation, giving sufficient time for intervention.

3. **Explainability drives adoption**: Customer success teams were skeptical until they could understand predictions at an individual customer level.

4. **Regular retraining is essential**: We observed model drift after 3 months, necessitating a monthly retraining schedule.

5. **Integration is as important as accuracy**: Even a slightly less accurate model that integrates well with existing workflows delivers more business value than a marginally more accurate model that's difficult to use.

## Future Enhancements

- **NLP analysis of customer communications**: Incorporating email, chat, and call transcripts
- **Earlier prediction window**: Expanding from 60-90 days to 90-120 days
- **Prescriptive recommendations**: Moving from identifying at-risk customers to recommending specific retention actions
- **Customer lifetime value integration**: Prioritizing retention efforts based on potential long-term value
- **Expansion prediction**: Identifying not just churn risk but also expansion opportunities

## Links

- [GitHub Repository](https://github.com/yourusername/churn-prediction)
- [Technical Documentation](https://docs.example.com/churn-prediction)
- [Research Paper](https://arxiv.org/abs/xxxx.xxxxx) 