use PortfolioProject;
-------------------------------------
-- CLEANING DATA IN SQL QUERIES--
-------------------------------------

select * from NashvilleHousing;

---------------------------------------
--Standardize date format

--select SaleDate, CONVERT(date, SaleDate) from NashvilleHousing;

ALTER TABLE NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);

--select SaleDate, SaleDateConverted from NashvilleHousing;

------------------------------------------------------------------

--Populate Property Address data

--select * from NashvilleHousing 
----where PropertyAddress is null
--order by PropertyAddress;

--select 
----a.[UniqueID ],
--a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
--from NashvilleHousing a
--join NashvilleHousing b
--on a.ParcelID = b.ParcelID
--and 
--a.[UniqueID ] != b.[UniqueID ]
--where a.PropertyAddress is null
----order by a.[UniqueID ];

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ];

----------------------------------------------------------------------

--Breaking out Address into individual columns(Address, City, State)

--select PropertyAddress from NashvilleHousing;

--select 
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
----,CHARINDEX(',',PropertyAddress)
--, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City

--from NashvilleHousing;

ALTER TABLE NashvilleHousing
add PropertySplitAddress Nvarchar(255);
update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);


ALTER TABLE NashvilleHousing
add PropertySplitCity Nvarchar(255);
update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

--select * from NashvilleHousing;
--select * from NashvilleHousing where OwnerAddress is null;

--select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
--,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
--,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
--from NashvilleHousing


ALTER TABLE NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
add OwnerSplitCity Nvarchar(255);

ALTER TABLE NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

--select * from NashvilleHousing;

----------------------------------------------------------------------------
---change Y and N to Yes and No in "Sold as vacant" field

select DISTINCT SoldAsVacant, COUNT(SoldAsVacant) from NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant;

update NashvilleHousing 
set SoldAsVacant = CASE
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
END
-------------------------------------------------------------------------------
--remove Duplicates

with RowNumCTE as (
select *
, ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
ORDER BY UniqueID
)row_num
from NashvilleHousing
)

--select *
delete
from RowNumCTE
where row_num >1;


---------------------------------------------------------------------------

--Delete Unused Columns

select * from NashvilleHousing;

alter table NashvilleHousing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
