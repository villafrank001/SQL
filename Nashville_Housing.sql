-- Cleaning Data

SELECT *
FROM dbo.NashvilleHousing;

------------------------------------------------------------------------------------------------------------------
--Standardize date format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM SQLTutorial.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) 

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM SQLTutorial.dbo.NashvilleHousing
--WHERE PropertyAddress is Null
ORDER BY ParcelID 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM SQLTutorial.dbo.NashvilleHousing a
JOIN SQLTutorial.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM SQLTutorial.dbo.NashvilleHousing a
JOIN SQLTutorial.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From SQLTutorial.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX (',', PropertyAddress)-1) as Address, 
	SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From SQLTutorial.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropAddress Nvarchar(255);

Update NashvilleHousing
SET PropAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropCity Nvarchar(255);

Update NashvilleHousing
SET PropCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--Double check it worked

Select *
From SQLTutorial.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From SQLTutorial.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Double check it worked
Select *
From SQLTutorial.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant)
From SQLTutorial.dbo.NashvilleHousing
GROUP BY SoldAsVacant
Order BY 2 --DOUBLE CHECK IT WORKED

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From SQLTutorial.dbo.NashvilleHousing;

UPDATE SQLTutorial.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

--Double check it worked

------------------------------------------------------------------------------------------------------------------

--Remove duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM SQLTutorial.dbo.NashvilleHousing)