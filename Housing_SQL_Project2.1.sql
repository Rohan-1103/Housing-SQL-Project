/*
	Cleaning data in SQL queries
*/

Select *
from PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SalesDateConverted, CONVERT(date, SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

alter table NashvilleHousing
add SalesDateConverted date

update NashvilleHousing
set SalesDateConverted = CONVERT(date, SaleDate)

------------------------------------------------------------------------------------------------------------------------------------------

-- Populated Property Address Data

Select ParcelID, PropertyAddress
from PortfolioProject..NashvilleHousing
order by ParcelID
--where PropertyAddress is null


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULl(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Property Address into Individual Columns (Address, City, State)

select PropertyAddress
from NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *from
PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Owner Address into Individual Columns (Address, City, State)

Select OwnerAddress
from PortfolioProject..NashvilleHousing

select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *from
PortfolioProject..NashvilleHousing
ORDER BY [UniqueID ]

------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant"

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
Order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant 
	 end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant= case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant 
	 end

------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as (
Select *, 
	ROW_NUMBER() over (
	partition by ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID) Row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where Row_num > 1

------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *from 
PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict
