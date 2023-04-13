SELECT 
	* 
FROM 
	NashvilleHousing


-- At first glance we can see that we have 19 total columns
-- We have 2 address columns, one for the property and another for the owner
-- It may be a good idea to break down the address column into seperate columns for city,state for analysis purposes
-- Sale date column appears to be in the incorrect format


----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------



-- FIXING SALES DATE COLUMN

--- adding new column for converted date
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

--- filling column with proper form from old column
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)




----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------


-- POPULATING PROPERTY ADDRESS DATA


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM 
	NashvilleHousing a
JOIN
	NashvilleHousing b
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]

--- from this output we can see that lines with the same parcel id have the same address for the property
--- address, we can therefore populate missing values accordingly



--- filling all null values in the property address based on the above observation
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM 
	NashvilleHousing a
JOIN
	NashvilleHousing b
	ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL






SELECT PropertyAddress
FROM 
	NashvilleHousing 
WHERE
	PropertyAddress IS NULL 

--- No more null values in this field of observation









----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------




-- BREAKING UP PROPERTY ADDRESS INTO MULTIPLE COLUMNS



SELECT 
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM 
	NashvilleHousing

--- charindex() grabs the index for the given char character
--- this allows us to split the column into two separate columns


--- adding new columns for split data
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

--- populating columns with splits we made before
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))






----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------




-- BREAKING UP OWNER ADDRESS INTO MULTIPLE COLUMNS



SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS OwnerSplitAddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS OwnerSplitCity,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS OwnerSplitState
FROM 
	NashvilleHousing

--- charindex() grabs the index for the given char character
--- this allows us to split the column into two separate columns


--- adding new columns for split data
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

--- populating columns with splits we made before
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)





--- I wanted to fill all null values for the owner address and city based on the property address and city because at first glance it seemed like
--- they were the same for all rows. So let us check if this is the case

SELECT PropertySplitAddress,PropertySplitCity,OwnerSplitAddress,OwnerSplitCity
FROM 
	NashvilleHousing 
WHERE PropertySplitAddress <> OwnerSplitAddress

--- we see that there are in fact over 5,000 rows where the property and owner address are NOT the same. I also found that there 
--- is one record where cities are not the same.
--- it seems there are some rows where the owner lives in the same duplex maybe but not in the same property that is being sold

--- Therefore we cannot fill in null values for the owner address and city





----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------




-- CHANGING 'Y' AND 'N' TO 'Yes' AND 'No' IN SoldAsVacant COLUMN

SELECT 
	DISTINCT SoldAsVacant, COUNT(SoldAsVacant) AS value_counts
FROM
	NashvilleHousing
GROUP BY SoldAsVacant

--- right now we have 'N','Yes','Y','No' so we want them to be uniform and either just 'Yes' or 'No'



UPDATE NashvilleHousing
SET SoldAsVacant =  
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--- this case functions sets values we want accordingly and if values are already how we want then it leaves as is






----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------



-- REMOVING DUPLICATES

WITH RowNum AS(
SELECT
	*,
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDateConverted, LegalReference ORDER BY UniqueID) row_num
FROM 
	NashvilleHousing
)
DELETE
FROM RowNum
WHERE row_num >1

--- the CTE in this code gathers all rows that have similar columns listed, then it adds a columns and lists the row numbers as 1 for each unique row
--- and then values greater than one for each duplicated row

--- we then extract all duplicated rows by the WHERE clause





--- now we check to see if they did get removed
WITH RowNum AS(
SELECT
	*,
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDateConverted, LegalReference ORDER BY UniqueID) row_num
FROM 
	NashvilleHousing
)
SELECT *
FROM RowNum
WHERE row_num >1





----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------



-- DELETE UNUSED COLUMNS

ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict, SaleDate, OwnerAddress, PropertyAddress




----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------



-- CLEANING UP 'LandUse' COLUMN


SELECT 
	LandUse, LEN(LandUse) as counts
FROM 
	NashvilleHousing
GROUP BY LandUse
ORDER BY LandUse

--- we can see that there are a few categories that can be combined like 'GREENBELT' can be added in with 'GREENBELT/RES GRRENBELT/RES'
--- and we also need to fix that misspelling and there seems to be an extra space in there

--- we can also fix the different variations of 'VACANT RESIDENTIAL LAND'



UPDATE NashvilleHousing
SET LandUse =  
	CASE WHEN LandUse = 'VACANT RES LAND' THEN 'VACANT RESIDENTIAL LAND'
	WHEN LandUse = 'VACANT RESIENTIAL LAND' THEN 'VACANT RESIDENTIAL LAND'
	WHEN LandUse = 'GREENBELT' THEN 'GREENBELT/RES GREENBELT/RES'
	WHEN LandUse = 'GRRENBELT/RES  GRRENBELT/RES' THEN 'GREENBELT/RES GREENBELT/RES'
	ELSE LandUse
	END

