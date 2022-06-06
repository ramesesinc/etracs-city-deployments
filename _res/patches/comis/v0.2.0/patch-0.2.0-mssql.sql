alter table lgu add name nvarchar(50)
go

alter table lgu add islocal int default 0
go 

update lgu set 
	name = objid,
	islocal = case when name like '%LIGAO%' then 1 else 0 end 
go

alter table cemetery add isoutsidelgu int default 0
go


exec sp_rename 'dbo.deceased.lgu', 'lgu_objid', 'COLUMN'
go 
exec sp_rename 'dbo.deceased.placeofdeath', 'placeofdeath_objid', 'COLUMN'
go 
exec sp_rename 'dbo.deceased.placeofburial', 'placeofburial_objid', 'COLUMN'
go 

drop index deceased.ix_lgu
go 
drop index deceased.ix_placeofdeath
go 
drop index deceased.ix_placeofdburial
go 

alter table deceased alter column lgu_objid nvarchar(50)
go 
alter table deceased alter column placeofdeath_objid nvarchar(50)
go 
alter table deceased alter column placeofburial_objid nvarchar(50)
go 

create index ix_lgu on deceased(lgu_objid)
go 
create index ix_placeofdeath on deceased(placeofdeath_objid)
go 
create index ix_placeofdburial on deceased(placeofburial_objid)
go 


alter table deceased 
	add constraint fk_deceased_placeofdeath foreign key (placeofdeath_objid)
	references lgu (objid)
go 


alter table deceased 
	add constraint fk_deceased_placeofburial foreign key (placeofburial_objid)
	references lgu (objid)
go 



alter table deceased add cemetery_name nvarchar(100)
go 

alter table deceased add cemetery_address nvarchar(100)
go 



alter table resource add allowmultiple int default 0
go 

update resource set allowmultiple = case when name = 'OSSUARY' then 1 else 0 end 
go 

