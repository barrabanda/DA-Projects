--Select data that we are going to be using
SELECT *
FROM Housing 

--Standartize SaleDate to date format
ALTER TABLE Housing
ADD SaleDateConverted date

UPDATE Housing
SET SaleDateConverted = CONVERT(date, SaleDate)

--Populate property address data
--If property address is null we add it using postal code 
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress IS NULL 

--Breaking out address column into individual columns (address, city, state)
--update table, adding columns with address and city separately
--split address
ALTER TABLE Housing 
ADD PropertySplitAddress Nvarchar(255);

UPDATE Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--split city
ALTER TABLE Housing 
ADD PropertySplitCity Nvarchar(255);

UPDATE Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--split address for owner address
ALTER TABLE Housing 
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) --splits the object name into parts based on the “.” delimiter

ALTER TABLE Housing 
ADD OwnerSplitCity Nvarchar(255);

UPDATE Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Housing 
ADD OwnerSplitState Nvarchar(255);

UPDATE Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No option in "Sold as Vacant" field
UPDATE Housing
SET SoldAsVacant = CASE
                       WHEN SoldAsVacant='Y' THEN 'Yes'
                       WHEN SoldAsVacant='N' THEN 'No'
                       ELSE SoldAsVacant
                   END 
				   
--Remove Duplicates
WITH RowNumCTE AS
  (SELECT *,
          ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                          PropertyAddress,
                                          SalePrice,
                                          SaleDate,
                                          LegalReference
                             ORDER BY UniqueID) row_num
   FROM Housing) 
   
DELETE FROM RowNumCTE
WHERE row_num > 1

--Delete unused columns
ALTER TABLE Housing
DROP COLUMN OwnerAddress,
            TaxDistrict,
            PropertyAddress,
            SaleDate