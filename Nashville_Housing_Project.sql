--Cleaning Data in SQL Queries//

Select *
From PortfolioProject..NashvilleHousing

--Standardize Date Format. Convert from datetime to date.

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT (Date,Saledate)

---Populate null Property Address data.
Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null
Order by ParcelID

--ParcelIDs share the same address.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Updated so ParcelIDs match null Property Address

Update a
SET  PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--Breaking out PropertyAddress into Individual Columns (Address,City,State) using SUBSTRINGS 

Select
SUBSTRING(PropertyAddress,1,CHARINDEX (',',PropertyAddress)-1) as Address
SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

--ADD COLUMN

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

--ADD ADDRESS TO NEW COLUMN

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX (',',PropertyAddress)-1)

--ADD COLUMN

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

--UPDATES COLUMN

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress) +1, LEN(PropertyAddress))

--CLEANING OUT OWNER ADDRESS WITH PARSENAME. First comma needs too be changed into a period. 

Select
PARSENAME(Replace (OwnerAddress,',','.'),3)
,PARSENAME(Replace (OwnerAddress,',','.'),2)
,PARSENAME(Replace (OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing

--ADD NEW COLUMNS AND INFO.

Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace (OwnerAddress,',','.'),3) 

Alter table NashvilleHousing
Add OwnerCity Nvarchar(255);

Update NashvilleHousing
SET OwnerCity = PARSENAME(Replace (OwnerAddress,',','.'),2)

Alter table NashvilleHousing
Add OwnerState Nvarchar(255);

Update NashvilleHousing
SET OwnerState = PARSENAME(Replace (OwnerAddress,',','.'),1)

--Realized row in column 'SoldAsVacant' were not uniformed

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

--Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant 
,	Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
From PortfolioProject..NashvilleHousing

--Update Colum

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END

--Remove Duplicates. Not done in regular circumstance, but I wanted to showcase how it can be done.

WITH RowNumCTE AS(
 Select *,
	row_number () OVER (
	Partition by ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate,
				LegalReference
				Order by UniqueID
				) as row_num
From PortfolioProject..NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num >1

--Example of how to delete columns. Going to remove OwneerAddress, PropertyAddress, 
--and SaleDate since I split them up into separe columns earlier.

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, SaleDate

----------------------------------------------------------------------------------------------------------