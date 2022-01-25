select count(*) from PortfolioProject..Nashville_Housing;
select count(*) from PortfolioProject..Sheet1$_xlnm#_FilterDatabase;
select * from PortfolioProject..Nashville_Housing;




--------------------------------------------------------------------------------
--Standardizing the saledate column (conversion from datetime to date format)
--------------------------------------------------------------------------------

select SaleDate from PortfolioProject..Nashville_Housing;

select SaleDate,CONVERT(date,saledate) as SaleDate2 from PortfolioProject..Nashville_Housing;



Alter table PortfolioProject.dbo.Nashville_Housing
add sale_date_converted Date;

update PortfolioProject.dbo.Nashville_Housing
set sale_date_converted = CONVERT(date,saleDate)

select * from PortfolioProject..Nashville_Housing;





--------------------------------------------------------------------------------
--Populating the property address data
--------------------------------------------------------------------------------



select count(*)
from PortfolioProject..Nashville_Housing
where PropertyAddress is null

select ParcelID, PropertyAddress
from PortfolioProject..Nashville_Housing
where propertyaddress is null
order by ParcelID

select * from PortfolioProject..Nashville_Housing

select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress) 
--if(a.propertyaddress is null) then (put b.propertyaddress in the new column)
from PortfolioProject..Nashville_Housing a
join PortfolioProject..Nashville_Housing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


update a
	set propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	from PortfolioProject..Nashville_Housing a
	join PortfolioProject..Nashville_Housing b 
		on a.ParcelID = b.ParcelID
		and a.[UniqueID ]<>b.[UniqueID ]
	where a.PropertyAddress is null



-----------------------------------------------------------------------------------------
--Breaking address into individual columns (Address,City,State)
-----------------------------------------------------------------------------------------



select propertyaddress 
from PortfolioProject..Nashville_Housing
order by 1

select SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) as address
from PortfolioProject..Nashville_Housing


select	propertyaddress,
		SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) as address1,
		--substring(expression,startingposition int, lenght int)
		--          column    ,  from where         , to where  

		--charindex() returns the index number of a character 
		
		SUBSTRING(PropertyAddress, CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress)) as address2
from PortfolioProject..Nashville_Housing


--now adding the substring address and city name into new columns
--creating new columns
alter table portfolioproject..Nashville_Housing
add PropertySplitAddress nvarchar(255)

alter table portfolioproject..Nashville_Housing
add PropertySplitcity nvarchar(255)

--Populating new columns
update PortfolioProject..Nashville_Housing
set PropertySplitAddress = SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) 

update PortfolioProject..Nashville_Housing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress)) 



--now we need to split owner's address
--since  owners address is properly delimeted therefore using parsename()
--but  parsename only works with strings  delimited with a period . 
--so we need to replace the  comma with a period
--also parsename() works  backwards on a string

select OwnerAddress
from PortfolioProject..Nashville_Housing

select PARSENAME(REPLACE(OwnerAddress,',', '.'),1) as OwnerSplitState,
		PARSENAME(REPLACE(OwnerAddress,',', '.'),2) as OwnerSplitCity,
		PARSENAME(REPLACE(OwnerAddress,',', '.'),3) as OwnerSplitAddress
from PortfolioProject..Nashville_Housing


alter table PortfolioProject..Nashville_Housing
add OwnerSplitAddress nvarchar(255) 

update PortfolioProject..Nashville_Housing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3) 

alter table PortfolioProject..Nashville_Housing
add OwnerSplitCity nvarchar(255) 

update PortfolioProject..Nashville_Housing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2) 


alter table PortfolioProject..Nashville_Housing
add OwnerSplitState nvarchar(255) 

update PortfolioProject..Nashville_Housing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1) 


select *
from PortfolioProject..Nashville_Housing



---------------------------------------------------------------------------------------------------------------
--sold as vacant field
---------------------------------------------------------------------------------------------------------------



select distinct soldasvacant from PortfolioProject..Nashville_Housing;

select distinct soldasvacant, count(soldasvacant)
from PortfolioProject..Nashville_Housing
group by SoldAsVacant;



select soldasvacant ,
	case 
		when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
		else soldasvacant
		end
from PortfolioProject..Nashville_Housing;


Update PortfolioProject..Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


select distinct SoldAsVacant from PortfolioProject..Nashville_Housing


-----------------------------------------------------------------------------------------------------------
--Remove Duplicates
-----------------------------------------------------------------------------------------------------------


select * from PortfolioProject..Nashville_Housing


--A quick summary of SQL RANK Functions
--ROW_Number	It assigns the sequential rank number to each unique record.
--RANK			It assigns the rank number to each row in a partition. It skips the number for similar values.
--Dense_RANK	It assigns the rank number to each row in a partition. It does not skip the number for similar values.


--so whats happening here is that row_num gives each unique row a number=1
--and then when a duplicate is found on these columns ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
--row_num becomes 2
--then we put the rows with row_num=2 in a cte
--next we delete those rows

WITH RowNumCTE  AS(
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

	From PortfolioProject..Nashville_Housing
	--order by ParcelID
	)
	Select *
	From RowNumCTE
	Where row_num > 1
	Order by PropertyAddress



--now to delete these duplicate rows we replace select * with DELETE
WITH RowNumCTE  AS(
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

	From PortfolioProject..Nashville_Housing
	--order by ParcelID
	)
	DELETE
	From RowNumCTE
	Where row_num > 1
	

-----------------------------------------------------------------------------------------------------------
--delete Unused Columns
-----------------------------------------------------------------------------------------------------------

select *
From PortfolioProject..Nashville_Housing


Alter table PortfolioProject..Nashville_Housing
drop column OwnerAddress, TaxDistrict, PropertyAddress,SaleDate