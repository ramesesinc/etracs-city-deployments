-- RPT TAX INCENTIVE
alter table rpttaxincentive_item alter column basicrate decimal(16,2) not null
go 
alter table rpttaxincentive_item alter column sefrate decimal(16,2) not null
go 