public class Product2Extension
{
    public List<ProductWrapper> productsToInsert { get; set; }

    public Product2Extension(ApexPages.StandardController controller)
    {
        this.productsToInsert = new List<ProductWrapper>();
        this.addRows();
    }

    public void AddRows()
    {
        for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++)
        {
            Product2 productRecord = new Product2();
            PriceBookEntry pricebookEntryRecord = new PriceBookEntry();

            ProductWrapper newProductWrapper = new ProductWrapper(productRecord, pricebookEntryRecord);
            this.productsToInsert.add(newProductWrapper);
        }
    }

    // we use SelectOption class to get the family picklist values
    public List<SelectOption> GetFamilyOptions()
    {
        List<SelectOption> familyOptions = new List<SelectOption>();
        SelectOption defaultOption = new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE);
        familyOptions.add(defaultOption);

        List<Schema.PicklistEntry> picklistValues = Constants.PRODUCT_FAMILY;
        for (Schema.PicklistEntry pv : picklistValues)
        {
            String label = pv.getLabel();
            String value = pv.getValue();
            SelectOption newSelectOption = new SelectOption(label, value);

            familyOptions.add(newSelectOption);
        }

        return familyOptions;
    }

    public List<ChartHelper.ChartData> GetInventory()
    {
        return ChartHelper.GetInventory();
    }

    public PageReference Save()
    {
        Savepoint sp = Database.setSavepoint();
        try
        {
            // we are going to unwrap the list of products wrappers to insert 
            // the real products and associated pricebook entries
            List<Product2> productsToInsert = new List<Product2>();
            List<PriceBookEntry> pricebookEntriesToInsert = new List<PriceBookEntry>();
            for (ProductWrapper pw : this.productsToInsert)
            {
                Product2 prodRecord = pw.productRecord;
                PriceBookEntry pbEntryRecord = pw.pricebookEntryRecord;
                if (
                  prodRecord.Name != null && 
                  prodRecord.Family != null && prodRecord.Family != Constants.SELECT_ONE && 
                  prodRecord.Initial_Inventory__c != null
                )
                {
                    productsToInsert.add(pw.productRecord);
                }
                if (pbEntryRecord.UnitPrice != null)
                {
                    pbEntryRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
                    pbEntryRecord.IsActive = true;
                    pricebookEntriesToInsert.add(pbEntryRecord);
                }
            }
            insert productsToInsert;
            for (integer i = 0; i < pricebookEntriesToInsert.size(); i++)
            {
                PriceBookEntry pbEntry = pricebookEntriesToInsert[i];
                pbEntry.Product2Id = productsToInsert[i].Id;
            }
            insert pricebookEntriesToInsert;
            // if successful clear the list and display an informational message
            apexPages.addMessage(
                new ApexPages.message(
                    ApexPages.Severity.INFO, 
                    productsToInsert.size() + ' Inserted'
                )
            );
            this.productsToInsert.clear(); // do not remove
            this.addRows(); // do not remove
        } 
        catch (Exception e)
        {
            // if an error occurs, display an error message
            apexPages.addMessage(
                new ApexPages.message(
                    ApexPages.Severity.ERROR, 
                    Constants.ERROR_MESSAGE
                )
            );
            Database.rollback(sp);
        }
        
        return null;
    }
    
    public class ProductWrapper
    {
        public Product2 productRecord { get; set; }
        public PriceBookEntry pricebookEntryRecord { get; set; }
        
        public ProductWrapper(Product2 productRecord, PriceBookEntry pricebookEntryRecord)
        {
            this.productRecord = productRecord;
            this.pricebookEntryRecord = pricebookEntryRecord;
        }
    }
}