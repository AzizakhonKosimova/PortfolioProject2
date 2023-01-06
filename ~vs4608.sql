--Cleaning Data in SQL queries

select * from PortfolioProject1..Nashville_housing;

--Standardize the Date Format

select SaleDate, CONVERT(date, Saledate)
from PortfolioProject1..Nashville_housing;

alter table Nashville_housing
add SaleDateConverted Date;

update Nashville_housing
set SaleDateConverted =  CONVERT(date, Saledate);

select * from PortfolioProject1..Nashville_housing;

--Populate Property Address Data

select PropertyAddress from PortfolioProject1..Nashville_housing;

select PropertyAddress from PortfolioProject1..Nashville_housing
where PropertyAddress is null;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
from PortfolioProject1..Nashville_housing a
join  PortfolioProject1..Nashville_housing b
on a.ParcelID =  b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject1..Nashville_housing a
join  PortfolioProject1..Nashville_housing b
on a.ParcelID =  b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

update a 
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject1..Nashville_housing a
join  PortfolioProject1..Nashville_housing b
on a.ParcelID =  b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

--Breaking out address into individual columns (Address, City, State)

select PropertyAddress from PortfolioProject1..Nashville_housing;

select 
SUBSTRING( PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING( PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress) ) as City

from PortfolioProject1..Nashville_housing;


alter table PortfolioProject1..Nashville_housing
add PropertySplitAddress nvarchar(225);

update PortfolioProject1..Nashville_housing
set PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1);

alter table PortfolioProject1..Nashville_housing
add PropertySplitCity nvarchar(225);

update PortfolioProject1..Nashville_housing
set PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress) );

select * from PortfolioProject1..Nashville_housing;

--

select OwnerAddress
from PortfolioProject1..Nashville_housing;

select 
PARSENAME(replace(OwnerAddress, ',','.'),3),
PARSENAME(replace(OwnerAddress, ',','.'),2),
PARSENAME(replace(OwnerAddress, ',','.'),1)
from PortfolioProject1..Nashville_housing;

alter table PortfolioProject1..Nashville_housing
add OwnerSplitAddress nvarchar(225);

update PortfolioProject1..Nashville_housing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',','.'),3);

alter table PortfolioProject1..Nashville_housing
add OwnerSplitCity nvarchar(225);

update PortfolioProject1..Nashville_housing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',','.'),2);

alter table PortfolioProject1..Nashville_housing
add OwnerSplitState nvarchar(225);

update PortfolioProject1..Nashville_housing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',','.'),1);

select * from PortfolioProject1..Nashville_housing;


--Change Y and N to 'Yes' and 'No' in "Sold as Vacant' field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject1..Nashville_housing
group by SoldAsVacant
order by COUNT(SoldAsVacant);

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from PortfolioProject1..Nashville_housing

update PortfolioProject1..Nashville_housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end


--Remove duplicates
--using cte and window function row_number (https://www.youtube.com/watch?v=1q__OqPqNc8) 

select * from  PortfolioProject1..Nashville_housing

with RowNumCTE as(
select *,
ROW_NUMBER () over (PARTITION by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by uniqueid) as row_num
from PortfolioProject1..Nashville_housing 
)

select * from RowNumCTE
where row_num > 1;

with RowNumCTE as(
select *,
ROW_NUMBER () over (PARTITION by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by uniqueid) as row_num
from PortfolioProject1..Nashville_housing 
)

delete from RowNumCTE
where row_num > 1;

--Delete unused columns

select * from PortfolioProject1..Nashville_housing ;

alter table PortfolioProject1..Nashville_housing 
drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate
