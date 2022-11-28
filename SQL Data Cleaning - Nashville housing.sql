-- Standardize Date Format


SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM ProjectPortfolio..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

-------------------------------------------

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

SELECT SaleDateconverted, CONVERT(DATE,SaleDate)
FROM ProjectPortfolio..NashvilleHousing

-- Populate Property Address data (ParcelID is the same but at least one of the address is null)

SELECT *
FROM ProjectPortfolio..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT nashville1.ParcelID,nashville1.PropertyAddress, nashville2.ParcelID, nashville2.PropertyAddress, ISNULL(nashville1.PropertyAddress, nashville2.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing nashville1
JOIN ProjectPortfolio..NashvilleHousing nashville2
	ON nashville1.ParcelID = nashville2.ParcelID
	AND nashville1.[UniqueID ] <> nashville2.[UniqueID ]
WHERE nashville1.PropertyAddress IS NULL

Update nashville1
SET Propertyaddress = ISNULL(nashville1.PropertyAddress, nashville2.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing nashville1
JOIN ProjectPortfolio..NashvilleHousing nashville2
	ON nashville1.ParcelID = nashville2.ParcelID
	AND nashville1.[UniqueID ] <> nashville2.[UniqueID ]
WHERE nashville1.PropertyAddress IS NULL


--Splitting the Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM ProjectPortfolio..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

SELECT *
FROM ProjectPortfolio..NashvilleHousing


--Splitting the Address into Individual Columns (Address, City, State)


SELECT OwnerAddress
FROM ProjectPortfolio..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerSplitAddress= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
FROM ProjectPortfolio..NashvilleHousing

-- Change Y AND N to Yes and No in "Sold as Vacant" field

SELECT soldasvacant, count(SoldasVacant)
FROM ProjectPortfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 Desc


SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM ProjectPortfolio..NashvilleHousing

UPDATE ProjectPortfolio..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


--Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) AS Row_num
FROM ProjectPortfolio..NashvilleHousing
)
SELECT * FROM RowNumCTE
WHERE Row_num > 1
ORDER BY PropertyAddress

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) AS Row_num
FROM ProjectPortfolio..NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE Row_num > 1

-- Delete Unused Columns

ALTER TABLE ProjectPortfolio..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE ProjectPortfolio..NashvilleHousing
DROP COLUMN SaleDate