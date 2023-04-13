    SQL Data Cleaning for Nashville Housing Dataset

Project Summary:

In this SQL data cleaning project, we perform an extensive data cleaning process on a Nashville housing dataset to ensure data quality and prepare the dataset for further analysis or reporting. The dataset contains various attributes related to housing sales, such as Parcel ID, Property Address, Owner Address, Sale Date, Sale Price, and Legal Reference.



The data cleaning process addresses several common data quality issues, such as missing values, duplicates, incorrect data types, and inconsistent formatting. The project's SQL script includes the following data cleaning steps:



    Fixing the Sale Date column:

Adding a new column for the converted date and filling it with the properly formatted date from the original Sale Date column.

    Populating missing Property Address data:

Identifying missing Property Address values and filling them based on other rows with the same Parcel ID.

    Breaking up Property Address into multiple columns:

Splitting the Property Address column into separate columns for Address and City.

    Breaking up Owner Address into multiple columns:

Splitting the Owner Address column into separate columns for Address, City, and State.

    Standardizing the SoldAsVacant column:

Changing 'Y' and 'N' values to 'Yes' and 'No' for consistency.

    Removing duplicate rows:

Identifying and deleting duplicate rows based on specific columns (ParcelID, PropertyAddress, SalePrice, SaleDateConverted, and LegalReference).

    Deleting unused columns:

Removing the unnecessary columns from the dataset (TaxDistrict, SaleDate, OwnerAddress, and PropertyAddress).

After performing these data cleaning steps, the Nashville housing dataset is now ready for further analysis or reporting. This project showcases the ability to clean and preprocess data using SQL, a critical skill for any data analyst.
