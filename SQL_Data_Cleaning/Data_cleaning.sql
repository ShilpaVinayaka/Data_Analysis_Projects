--- Cleaning Data in SQL Queries

SELECT * FROM PortfolioProject..NashvilleHousing$

--- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate) 
FROM PortfolioProject..NashvilleHousing$

UPDATE NashvilleHousing$
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing$
ADD SaleDateConverted Date

UPDATE NashvilleHousing$
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing$

-------------------------------------------------------------------------

--- Populate Property Address data
SELECT *
FROM PortfolioProject..NashvilleHousing$
WHERE PropertyAddress is NULL

--- Checking duplicates
SELECT *
FROM PortfolioProject..NashvilleHousing$
ORDER BY ParcelID

--- Joining 
SELECT *
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$  b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID];

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
	ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$  b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID]
WHERE a.PropertyAddress is NULL;

UPDATE a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$  b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID]
WHERE a.PropertyAddress is NULL;

---- Repeat previous query to check if UPDATE worked

-------------------------------------------------------------------------

--- Breaking out Address into Individual Columns (Address, City, State) 
--- Using SUBSTRING

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing$

-- Splitting PropertyAddress Column
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing$

-- Getting rid of comma delimeter
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
CHARINDEX(',', PropertyAddress)
FROM PortfolioProject..NashvilleHousing$

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing$

--- Adding the created split columns

ALTER TABLE NashvilleHousing$
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing$
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, 
									LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing$


--- Splitting Owner Address: New Method
--- USing PARSENAME

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing$

SELECT PARSENAME(REPLACE(OwnerAddress,',', '.'),3), 
	   PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
	   PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM PortfolioProject..NashvilleHousing$

--- Adding new Columns to tables

ALTER TABLE NashvilleHousing$
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)


ALTER TABLE NashvilleHousing$
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)


ALTER TABLE NashvilleHousing$
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

--- Checking the changes
SELECT *
FROM PortfolioProject..NashvilleHousing$

-------------------------------------------------------------------------
--- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing$
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing$

UPDATE NashvilleHousing$
SET SoldAsVacant = CASE 
					WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
				   END
-------------------------------------------------------------------------
--- Remove Duplicates

-- Deleting duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
				) row_num

FROM PortfolioProject..NashvilleHousing$
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Check the table for duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
				) row_num

FROM PortfolioProject..NashvilleHousing$
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT *
FROM PortfolioProject..NashvilleHousing$

-------------------------------------------------------------------------
--- Delete unused columns
SELECT *
FROM PortfolioProject..NashvilleHousing$

ALTER TABLE PortfolioProject..NashvilleHousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing$
DROP COLUMN SaleDate
