# Setup Guide for Azure Weather & Air Pollution Analytics

## Prerequisites
- Azure subscription (Azure for Students or other subscription)
- OpenWeather API access (sign up at https://openweathermap.org/api)
- Power BI Desktop (for local visualization)

## Deployment Instructions

### 1. Deploy Azure Resources
You can deploy all resources using the ARM template provided in this repository:

1. Go to Azure Portal (https://portal.azure.com)
2. Search for "Deploy a custom template"
3. Click "Build your own template in the editor"
4. Copy the content from `infrastructure/arm-template/template.json`
5. Click "Save"
6. Fill in the parameters:
   - Resource Group: Create new or use existing
   - Region: East US 2
   - Other parameters as prompted
7. Click "Review + create" then "Create"

### 2. Configure Function App
1. Navigate to the deployed Function App
2. Add the following Application Settings:
   - OPENWEATHER_API_KEY: Your OpenWeather API key
   - STORAGE_CONNECTION_STRING: Connection string to your storage account

### 3. Configure Data Factory
1. Open Azure Data Factory Studio
2. Configure linked services for:
   - Azure Storage
   - Azure Synapse
   - OpenWeather API

### 4. Set Up Power BI
1. Download the .pbix file from this repository
2. Open in Power BI Desktop
3. Update data source connections
4. Publish to Power BI Service (optional)

## Verification Steps
1. Trigger the Azure Function manually to collect initial data
2. Verify data is flowing through the pipeline
3. Check the Power BI dashboard for visualization

## Troubleshooting
- Check Azure Function logs for API connection issues
- Verify storage permissions
- Ensure all connection strings are properly configured
