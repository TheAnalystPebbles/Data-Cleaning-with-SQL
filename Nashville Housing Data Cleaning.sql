--Cleaning Data With SQL Queries
--Let's view the table

SELECT *
FROM Portfolio_Project..NashvilleHousing

--Standardize Date Format

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM Portfolio_Project..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD NewSaleDate DATE

UPDATE NashvilleHousing
SET NewSaleDate = CONVERT(DATE, SaleDate)

SELECT NewSaleDate
FROM Portfolio_Project..NashvilleHousing

--Populate Property Address Data

SELECT PropertyAddress
FROM Portfolio_Project..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM Portfolio_Project..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM Portfolio_Project..NashvilleHousing
ORDER BY ParcelID

--We can note that people with the same Parcel ID have the same property address, so we can populate the empty property address by looking at the parcel ID 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project..NashvilleHousing a
JOIN Portfolio_Project..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b. UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project..NashvilleHousing a
JOIN Portfolio_Project..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b. UniqueID
WHERE a.PropertyAddress IS NULL

--Breaking out Property and Owner Address into Individual Columns (Address, City, State)
--Let's start with the Property Address

SELECT PropertyAddress
FROM Portfolio_Project..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM Portfolio_Project..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


--Let's do te same for the Owner Address

SELECT OwnerAddress
FROM Portfolio_Project..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio_Project..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No in the SoldAsVacant Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Portfolio_Project..NashvilleHousing

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

	--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				    UniqueID
					) row_num
FROM Portfolio_Project..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--DELETE
--FROM RowNumCTE
--WHERE row_num > 1


--Delete Unwanted Columns

SELECT *
FROM Portfolio_Project..NashvilleHousing

ALTER TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN SaleDate