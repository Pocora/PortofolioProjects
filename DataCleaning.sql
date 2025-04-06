/* 
Cleaning Data in SQL Queries

*/

--------------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format


use PortofolioProject1

select SaleDate,  SaleDateConverted , CONVERT(date, saleDate)
from PortofolioProject1.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(date, saledate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

----------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data


select * 
from PortofolioProject1.dbo.NashvilleHousing
-- WHERE PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortofolioProject1.dbo.NashvilleHousing a
JOIN PortofolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortofolioProject1.dbo.NashvilleHousing a
JOIN PortofolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


----------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortofolioProject1.dbo.NashvilleHousing

SELECT 
SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
--CHARINDEX(',', PropertyAddress)
, SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from PortofolioProject1.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT * 
from PortofolioProject1.dbo.NashvilleHousing



SELECT OwnerAddress 
from PortofolioProject1.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress,',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
from PortofolioProject1.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

SELECT * 
from PortofolioProject1.dbo.NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortofolioProject1.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortofolioProject1.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


------------------------------------------------------------------------------------------------------------------------------------------
 
 --Remove Duplicates

 With RowNumCTE AS (
 Select *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

 from PortofolioProject1.dbo.NashvilleHousing
-- Order BY ParcelID
 )
 Select * 
 -- DELETE
 from RowNumCTE
 Where row_num > 1
Order by PropertyAddress

 ------------------------------------------------------------------------------------------------------------------------------------------
 -- Delete Unused Columns

 Select * 
 from PortofolioProject1.dbo.NashvilleHousing

 ALTER TABLE PortofolioProject1.dbo.NashvilleHousing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

  ALTER TABLE PortofolioProject1.dbo.NashvilleHousing
 DROP COLUMN SaleDate


 ------------------------------------------------------------------------------------------------------------------------------------------
  -- END
