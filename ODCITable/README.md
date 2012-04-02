Select from a "table" with 7 columns and 5 rows:

    select * from table(DynamicTable.Go(7,5));

Select from a "table" with 1 column and 1000 rows:

    select * from table(DynamicTable.Go(1,1000));
