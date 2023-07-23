Select*
From PortfolioProject1..NHousing$

--Standardised Date Format

Select SaleDateConverted, CONVERT (Date, SaleDate)
From PortfolioProject1.dbo.NHousing$

Update NHousing$
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NHousing$
Add SaleDateConverted Date;

Update NHousing$
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data

Select *
From PortfolioProject1..NHousing$
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject1..NHousing$ a
JOIN PortfolioProject1..NHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID
Where a.PropertyAddress IS null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject1..NHousing$ a
JOIN PortfolioProject1..NHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID


--Breaking out Address into individual column (Address, City, State)

Select PropertyAddress
From PortfolioProject1..NHousing$
--Where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject1..NHousing$


ALTER TABLE PortfolioProject1..NHousing$
Add PropertySplitAddress Nvarchar (255);

Update PortfolioProject1..NHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject1..NHousing$
Add PropertySplitCity nvarchar (255);

Update PortfolioProject1..NHousing$
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select*
From PortfolioProject1..NHousing$

Select OwnerAddress
From PortfolioProject1..NHousing$

Select
PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject1..NHousing$



ALTER TABLE PortfolioProject1..NHousing$
Add OwnerSplitAddress Nvarchar (255);

Update PortfolioProject1..NHousing$
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject1..NHousing$
Add OwnerSplitCity nvarchar (255);

Update PortfolioProject1..NHousing$
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE PortfolioProject1..NHousing$
Add OwnerSplitState nvarchar (255);

Update PortfolioProject1..NHousing$
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)


Select*
From PortfolioProject1..NHousing$


--Chane Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct (SoldAsVacant), Count (SoldAsVacant)
From PortfolioProject1..NHousing$
Group by SoldAsVacant
Order by 2

Select SoldASVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
	   END
From PortfolioProject1..NHousing$

Update PortfolioProject1..NHousing$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
	   END

--Remove Duplicates
WITH RowNumCTE AS (
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
From PortfolioProject1..NHousing$
--Order by parcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



-- Delete unused Columns 

Select *
From PortfolioProject1..NHousing$

ALTER TABLE PortfolioProject1..NHousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject1..NHousing$
DROP COLUMN SaleDate