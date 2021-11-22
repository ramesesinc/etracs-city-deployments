-- RPT TAX INCENTIVE
alter table rpttaxincentive_item modify column basicrate decimal(16,2) not null
;
alter table rpttaxincentive_item modify column sefrate decimal(16,2) not null
;

