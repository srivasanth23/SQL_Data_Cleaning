/* Data Cleaning */

Select * from PortfolioProject..NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
-- Here problem is we need to converts datetime into date [because time is 00:00:00 in all cases and it an unwanted requirment]

Select SaleDate, CONVERT(date, SaleDate) from PortfolioProject..NashvilleHousing;

Alter table NashvilleHousing 
add SalesDateConverted date;   --> Adds new Column

Update NashvilleHousing 
Set SalesDateConverted = CONVERT(date, SaleDate); --> updates converted values

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select PropertyAddress, ParcelID 
from PortfolioProject..NashvilleHousing;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--> Meaning of this code [where the propertyAddress is null, add the new column address there] 

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
from PortfolioProject..NashvilleHousing as a
join PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--> MOTC [ in table A update column Propertyaddress to new value]

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProject..NashvilleHousing

Select 
substring (PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) as Address
, substring (PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Alter table PortfolioProject..NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
set PropertySplitAddress = substring (PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)


Update PortfolioProject..NashvilleHousing
set PropertySplitCity = substring (PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , len(PropertyAddress))



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Alter table PortfolioProject..NashvilleHousing
add OWnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Update PortfolioProject..NashvilleHousing
SET OWnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant
from PortfolioProject..NashvilleHousing


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
	case when SoldAsVacant = 'Y' Then 'Yes'
		 when SoldAsVacant = 'N' Then 'No'
		 else SoldAsVacant
		 End
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
		 when SoldAsVacant = 'N' Then 'No'
		 else SoldAsVacant
		 End

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowCTE as(
select * ,
	ROW_NUMBER() over (
	partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 Order by uniqueId) as row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
Select * from RowCTE
Where row_num > 1
Order by PropertyAddress


Delete 
from RowCTE
Where row_num > 1

---------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate