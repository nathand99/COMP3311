--List all the company names (and countries) that are incorporated outside Australia.
    create or replace view Q1(Name, Country) as select name, country from company where country <> 'Australia';

--List all the company codes that have more than five executive members on record (i.e., at least six).
    create or replace view Q2(Code) as select code from executive group by code having count(code) > 5 order by code asc;

--List all the company names that are in the sector of "Technology"
    create or replace view Q3(Name) as select name from company join category on company.code = category.code where sector = 'Technology';

--Find the number of Industries in each Sector
    create or replace view Q4(Sector, Number) as select sector, count(distinct industry) from category group by sector order by sector ASC;
    
--Find all the executives (i.e., their names) that are affiliated with companies in the sector of "Technology". If an executive is affiliated with more than one company, he/she is counted if one of these companies is in the sector of "Technology".
    create or replace view Q5(Name) as select distinct person from executive join company on executive.code = company.code join category on executive.code = category.code where sector = 'Technology';

--List all the company names in the sector of "Services" that are located in Australia with the first digit of their zip code being 2.
    create or replace view Q6(Name) as select name from company join category on company.code = category.code where sector = 'Services' and country = 'Australia' and zip LIKE '2%';

--Create a database view of the ASX table that contains previous Price, Price change (in amount, can be negative) and Price gain (in percentage, can be negative). (Note that the first trading day should be excluded in your result.) For example, if the PrevPrice is 1.00, Price is 0.85; then Change is -0.15 and Gain is -15.00 (in percentage but you do not need to print out the percentage sign).
    create or replace view Q7("Date", Code, Volume, PrevPrice, Price, Change, Gain) as select a1."Date", a1.code, a1.volume, a2.price as "PrevPrice", a1.price as "Price", (a1.price - a2.price) as "Change", (a1.price - a2.price) / a2.price * 100 as "Gain" from asx a1 join asx a2 on a1."Date" = (a2."Date" + 1) and a1.code = a2.code group by a1.code, a1."Date", a1.volume, a2.price order by a1.code, a1."Date", a1.volume, a2.price;
    --NOTFINISHED 
    
--Find the most active trading stock (the one with the maximum trading volume; if more than one, output all of them) on every trading day. Order your output by "Date" and then by Code.
    create or replace view Q8("Date", Code, Volume) as select "Date", code, volume from asx where volume in (select max(volume) from asx group by "Date" order by "Date") order by "Date", code; 
    -- select max(volume), "Date" from asx group by "Date" order by "Date"; -- gives max volume for each day    

--Find the number of companies per Industry. Order your result by Sector and then by Industry.
    create or replace view Q9(Sector, Industry, Number) as select sector, industry, count(code) from category group by industry, sector  order by sector, industry;

--List all the companies (by their Code) that are the only one in their Industry (i.e., no competitors).
    create or replace view Q10(Code, Industry) as select code, industry from category where industry IN (select industry from category group by industry having count(industry) = 1);

--List all sectors ranked by their average ratings in descending order. AvgRating is calculated by finding the average AvgCompanyRating for each sector (where AvgCompanyRating is the average rating of a company).
    create or replace view Q11(Sector, AvgRating) as select category.sector, avg(rating.star) as "AvgRating" from rating join category on rating.code = category.code group by category.sector order by "AvgRating" desc;

--Output the person names of the executives that are affiliated with more than one company.
    create or replace view Q12(Name) as select person from executive group by person having count(person) > 1 order by person;

--Find all the companies with a registered address in Australia, in a Sector where there are no overseas companies in the same Sector. i.e., they are in a Sector that all companies there have local Australia address.
    create or replace view Q13(Code, Name, Address, Zip, Sector) as select company.code, company.name, company.address, company.zip, category.sector from company join category on company.code = category.code where sector in ((select distinct sector from category) except (select distinct category.sector from company join category on company.code = category.code where country <> 'Australia'));


--Calculate stock gains based on their prices of the first trading day and last trading day (i.e., the oldest "Date" and the most recent "Date" of the records stored in the ASX table). Order your result by Gain in descending order and then by Code in ascending order.
    create or replace view Q14(Code, BeginPrice, EndPrice, Change, Gain) as select a1.code, a2.price as "BeginPrice", a1.price as "EndPrice", (a1.price - a2.price) as "Change", (a1.price - a2.price) / a2.price * 100 as "Gain" from asx a1 join asx a2 on a1.code = a2.code where a1."Date" IN (select max("Date") from asx) and a2."Date" in (select min("Date") from asx) group by "Gain",a1.code, a2.price, a1.price, "Change" order by "Gain" desc, a1.code asc;

--For all the trading records in the ASX table, produce the following statistics as a database view (where Gain is measured in percentage). AvgDayGain is defined as the summation of all the daily gains (in percentage) then divided by the number of trading days (as noted above, the total number of days here should exclude the first trading day).
--    create or replace view Q15(Code, MinPrice, AvgPrice, MaxPrice, MinDayGain, AvgDayGain, MaxDayGain) as select code, min(price) as "MinPrice", avg(price) as "AvgPrice", count(code) from asx group by code;
--NOTFINISHED not enough columns

--Create a trigger on the Executive table, to check and disallow any insert or update of a Person in the Executive table to be an executive of more than one company. 
    CREATE OR REPLACE FUNCTION executive_check()
    RETURNS trigger as $$
    BEGIN
        select person from executive where old.person = new.person;
        if (found) then
            raise exception 'Person % cannot by executive of more than one company %',new.person;
        end if;
        return new.person;
    END;
    $$ language plpgsql;
    
    CREATE TRIGGER exec_trigger
    BEFORE INSERT OR UPDATE
    ON executive
    FOR EACH ROW
    EXECUTE PROCEDURE executive_check(); 

--Suppose more stock trading data are incoming into the ASX table. Create a trigger to increase the stock's rating (as Star's) to 5 when the stock has made a maximum daily price gain (when compared with the price on the previous trading day) in percentage within its sector. For example, for a given day and a given sector, if Stock A has the maximum price gain in the sector, its rating should then be updated to 5. If it happens to have more than one stock with the same maximum price gain, update all these stocks' ratings to 5. Otherwise, decrease the stock's rating to 1 when the stock has performed the worst in the sector in terms of daily percentage price gain. If there are more than one record of rating for a given stock that need to be updated, update (not insert) all these records. You may assume that there are at least two trading records for each stock in the existing ASX table, and do not worry about the case that when the ASX table is initially empty. 

--Stock price and trading volume data are usually incoming data and seldom involve updating existing data. However, updates are allowed in order to correct data errors. All such updates (instead of data insertion) are logged and stored in the ASXLog table. Create a trigger to log any updates on Price and/or Voume in the ASX table and log these updates (only for update, not inserts) into the ASXLog table. Here we assume that Date and Code cannot be corrected and will be the same as their original, old values. Timestamp is the date and time that the correction takes place. Note that it is also possible that a record is corrected more than once, i.e., same Date and Code but different Timestamp.
