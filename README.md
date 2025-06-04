# E-commerce Business Intelligence Project: End-to-End ETL & Interactive Dashboards

## 🎯 Project Overview

This project delivers a comprehensive Business Intelligence solution for an e-commerce business, transforming raw sales data into actionable insights through a robust ETL pipeline, a star schema data warehouse, and interactive Power BI dashboards.

The core objective is to enable data-driven decision-making by providing a 360-degree view of business performance, customer behavior, and product trends. This solution showcases a complete BI lifecycle, from data ingestion and cleaning to advanced analytics and visualization.

**Key Achievements:**
* **Processed over 540,000 transaction records:** Demonstrated capability in handling substantial datasets while ensuring data quality and integrity.
* **Designed & Implemented a Star Schema Data Warehouse:** Created an optimized relational database schema for efficient data retrieval and analytical querying.
* **Developed a Robust ETL Pipeline:** Automated the Extract, Transform, and Load processes, ensuring data accuracy and timeliness.
* **Created Comprehensive Power BI Dashboards:** Delivered a suite of interactive dashboards tailored for executive, operational, customer, and product intelligence.
* **Applied Advanced DAX & Power BI Features:** Utilized sophisticated analytical calculations and enhanced user experience through drill-throughs, bookmarks, and dynamic elements.

## 🛠️ Technical Stack

| Category                     | Tool / Technology                   | Description                                                                     |
| :--------------------------- | :---------------------------------- | :------------------------------------------------------------------------------ |
| **Data Ingestion & Cleaning** | Python (Pandas, pyodbc)             | Scripts for initial data loading, cleaning, and preparation before database insertion. |
| **Database Management** | SQL Server Express                  | Hosts the staging area and the optimized Star Schema Data Warehouse.            |
| **ETL & Data Transformation**| SQL (T-SQL)                         | Developed stored procedures and views for data manipulation, aggregation, and business logic implementation. |
| **Data Modeling & Viz.** | Power BI Desktop                    | Employed for creating interactive dashboards, defining the semantic model, and implementing complex DAX measures. |
| **Version Control** | Git & GitHub                        | Managed project source code, facilitated collaborative development, and tracked all changes. |
| **Development Environment** | Visual Studio Code                  | Primary IDE used for script development, SQL query authoring, and project management. |

## 🚀 Project Architecture & Data Flow

The project adheres to a standard Business Intelligence architectural pattern, designed for data integrity, performance, and scalability.

1.  **Raw Data Ingestion:**
    * E-commerce transaction data (CSV/Excel) is initially stored in the `data/raw` directory.
2.  **Staging Layer (SQL Server):**
    * Python scripts (`python/scripts/02_load_data_to_sql.py`) connect to SQL Server and load the cleaned raw data into the `staging.raw_sales` table.
3.  **ETL Process (SQL Server):**
    * A master ETL script (`sql/etl/00_run_full_etl.sql`) orchestrates the transformation:
        * **Date Dimension (`dw.DimDate`):** Populated with a comprehensive range of dates and attributes.
        * **Customer Dimension (`dw.DimCustomer`):** Populated with unique customer information and calculated attributes like `FirstPurchaseDate`, `LastPurchaseDate`, `TotalOrders`, and `TotalSpent`.
        * **Product Dimension (`dw.DimProduct`):** Populated with unique product details, including a custom `Category` based on description keywords.
        * **Sales Fact Table (`dw.FactSales`):** The central table, linking dimensions via surrogate keys and storing transactional metrics (`Quantity`, `UnitPrice`, `TotalAmount`).
4.  **Business Analysis Views (SQL Server):**
    * Pre-joined and aggregated views (`dw.vw_SalesSummary`, `dw.vw_MonthlySales`, `dw.vw_CustomerAnalysis`, `dw.vw_ProductPerformance`) are created on top of the data warehouse. These views simplify data consumption for Power BI and optimize query performance.
5.  **Power BI Visualization:**
    * Power BI Desktop connects directly to these SQL Server views, building an interactive data model, defining DAX measures, and creating the final dashboards.

## 📈 Visual Showcase

Below are key visual outputs from the project, demonstrating the progression from raw data insights to final interactive dashboards.

### 1. Initial Data Exploration

Before beginning transformations, an in-depth data exploration was conducted using Python. This provided critical insights into data quality issues such as missing values, data type inconsistencies, and outlier distributions, which were then addressed in the cleaning phase.

![Initial Data Exploration Plots showing missing values, data types, records over time, and quantity distribution](images/data_exploration.jpg)
*Visualizations like missing value heatmaps and distribution plots were instrumental in understanding the dataset's characteristics and informing the data cleaning strategy.*

### 2. Executive Overview Dashboard

This dashboard serves as the central hub for leadership, providing a high-level summary of critical business performance indicators.

![Executive Overview Dashboard displaying key KPIs, revenue per quarter, category distribution, and product summary](images/Executive%20Overview%20Dashboard.jpg)
*It presents key metrics such as Total Revenue, Total Products Sold, Total Customers, and Average Order Value, alongside visualizations for revenue trends and top product performance.*

### 3. Customer Analysis Dashboard

Focused on understanding and segmenting the customer base, this dashboard provides insights into customer behavior, acquisition, and engagement.

![Customer Analysis Dashboard showing customer portfolio overview, top customers by revenue, and customer acquisition trend](images/Customer%20Analysis%20Dashboard.png)
*Key components include a customer portfolio overview segmented by value, a trend line for customer acquisition, and a detailed list of top customers by revenue.*

### 4. Operational Dashboard

Designed for operational teams, this dashboard offers detailed sales performance metrics by country and product category, aiding in strategic adjustments and identifying areas for improvement.

![Operational Dashboard showing revenue comparison by country, low performer categories, and revenue vs quantity trend analysis](images/Operational%20Dashboard.jpg)
*Features include a year-over-year revenue comparison by country, identification of low-performing product categories, and a monthly trend analysis of total sales and quantity sold.*

## ⚙️ How to Set Up and Run the Project

To set up and run this project locally, follow these steps:

### Prerequisites:
* **Python 3.9+:** Ensure "Add Python to PATH" is selected during installation.
* **SQL Server Express:** Download and install the free version of SQL Server.
* **SQL Server Management Studio (SSMS):** For managing your SQL Server instance and executing SQL scripts.
* **Power BI Desktop:** Download and install the free data visualization tool.
* **Git:** For cloning the repository.
* **Visual Studio Code:** Recommended for code editing and project management.

### Setup Steps:

1.  **Clone the Repository:**
    Open your terminal or command prompt and run:
    ```bash
    git clone [https://github.com/YOUR-USERNAME/ecommerce-business-intelligence.git](https://github.com/YOUR-USERNAME/ecommerce-business-intelligence.git)
    cd ecommerce-business-intelligence
    ```

2.  **Set Up Python Environment & Install Dependencies:**
    ```bash
    python -m venv venv
    # For Windows:
    venv\Scripts\activate
    # For Mac/Linux:
    source venv/bin/activate
    pip install -r requirements.txt
    ```

3.  **Download Raw Dataset:**
    * Obtain the `data.csv` file from [Kaggle: E-Commerce Data](https://www.kaggle.com/datasets/carrie1/ecommerce-data) or the `Online Retail.xlsx` file from [UCI Machine Learning Repository: Online Retail](https://archive.ics.uci.edu/ml/datasets/Online+Retail).
    * Place the downloaded file into the `data/raw/` directory of your project (e.g., `data/raw/ecommerce_data.csv`).

4.  **Create SQL Server Database & Tables:**
    * Open **SQL Server Management Studio (SSMS)**.
    * Execute the script: `sql/schema/01_create_database.sql` to create the `ECommerceAnalytics` database.
    * Execute the script: `sql/schema/02_create_tables.sql` to create the `staging.raw_sales` table and all data warehouse (`dw`) dimension and fact tables.

5.  **Load Raw Data into SQL Server Staging:**
    * With your Python virtual environment activated, run the Python script:
        ```bash
        python python/scripts/02_load_data_to_sql.py
        ```
    * This script will clean the raw data and efficiently load it into the `staging.raw_sales` table.

6.  **Execute the ETL Process:**
    * In SSMS, open and execute the master ETL script: `sql/etl/00_run_full_etl.sql`.
    * This script will orchestrate the full ETL process, populating all `dw` dimension tables (`DimDate`, `DimCustomer`, `DimProduct`), the `FactSales` table, and creating the necessary business analysis views in the `dw` schema.

7.  **Open and Explore Power BI Dashboard:**
    * Open the Power BI Desktop application.
    * Open the `.pbix` file located in the `powerbi/` folder (you'll create this file as you build your Power BI dashboards based on the provided guide).
    * Ensure the data source settings within Power BI are configured to connect to your local SQL Server instance (typically `localhost` or `.\SQLEXPRESS`) using Windows Authentication.

## 📂 Project Structure
ecommerce-business-intelligence/
├── data/
│   ├── raw/                 # Contains the raw downloaded datasets (e.g., ecommerce_data.csv)
│   └── processed/           # (Optional) Directory for cleaned/intermediate datasets if used in Python
├── sql/
│   ├── schema/              # SQL scripts for database and initial table creation (e.g., 01_create_database.sql)
│   ├── etl/                 # SQL scripts for the ETL process, populating dimensions and facts (e.g., 00_run_full_etl.sql)
│   └── analysis/            # SQL scripts for creating business analysis views and advanced queries
├── python/
│   ├── notebooks/           # Jupyter notebooks for ad-hoc data exploration and prototyping
│   └── scripts/             # Python scripts for data loading, cleaning, and database interaction (e.g., 02_load_data_to_sql.py)
├── powerbi/                 # Stores Power BI Desktop files (.pbix) and connection guides
├── images/                  # Contains screenshots of dashboards and data exploration visuals
├── docs/                    # Comprehensive project documentation (e.g., project_overview.md, technical_architecture.md)
└── requirements.txt         # Lists all Python package dependencies for easy installation

## ✍️ Author

[Daniel Liu/danieljingtailiu](https://github.com/danieljingtailiu)

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for more details.

---