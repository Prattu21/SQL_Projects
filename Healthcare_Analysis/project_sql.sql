create database project;

use project;

#BASIC LEVEL
# Read all files
select * from disease_hospital_map;
select * from hospital_master;
select * from patient_master;
select * from patient_ratings;
select * from visit_record;

#1.Show all records from patient_master.
select * from hospital_master;

#2.Show the Name and City of all patients.
select Name,City from patient_master;

#3.Show all hospitals in Pune.
select * from hospital_master where city like '%Pune%'; 

#4.Show diseases treated in each hospital.
SELECT dhm.disease, hospitalname
FROM disease_hospital_map dhm
JOIN hospital_master h ON dhm.Specialization = h.Specialization;

#5.Count how many patients are from Mumbai.
select count(PatientID) from patient_master where city like 'Mumbai';

#6.List all male patients.
select * from patient_master where gender = 'M';

#7.Show hospitals with a rating greater than 4.
select * from patient_ratings where rating > 4;

#8.Show the total number of hospitals.
select count(HospitalID) from hospital_master;

#9.Show unique diseases from patient_master.
select distinct(disease) from patient_master;

#10.Show all visits from visit_record.
select * from visit_record;

#11.Show the highest hospital rating.
select rating from patient_ratings
order by rating desc limit 1;

#12.Show the lowest hospital rating
select rating from patient_ratings
order by rating limit 1;

#13.Show all visits happened on a specific date.
select * from visit_record;
select * from visit_record where visitdate = '2024-03-02';

#14.Show the patient details whose PatientID = 10.
select * from patient_master;
select * from patient_master where PatientID = 'P010';

#15.Show hospital names and their cities.
select hospitalname,city from hospital_master;

#INTERMEDIATE LEVEL
#16.Count patients grouped by city.
select city,count(PatientID) from patient_master
group by city;

#17.Count hospitals by specialization.
select Specialization,count(HospitalID) from hospital_master
group by Specialization;

#18.Show hospitals that treat ‘Cardiac’ disease (use join).
select h.hospitalname,dhm.disease from disease_hospital_map dhm
join hospital_master h
on h.Specialization=dhm.Specialization
where dhm.Specialization like '%Cardiology%';

#19.Show patients with their visited hospital name.
select vc.patientID,hm.hospitalname from visit_record vc
join hospital_master hm
on vc.hospitalID=hm.hospitalID
join patient_master pm 
on vc.patientID=pm.patientID;

#20.Find patients who visited more than 1 time.
select patientID ,count(VisitID) from visit_record
group by patientID
having count(VisitID) > 1;

#21.Find hospitals whose rating is between 3 and 5.
select * from hospital_master where rating between 3 and 5;

#22.Show the top 5 patients based on age.
select * from patient_master
order by age desc limit 5;

#23.Show hospital details along with diseases they treat.
select h.hospitalname,dhm.disease from hospital_master h
join disease_hospital_map dhm
on h.Specialization=dhm.Specialization;

#24.Find which disease is most common among patients.
select disease from patient_master 
group by disease
order by count(PatientID) desc limit 1;

#25.Find total bills generated for all visits.
select sum(totalbill) from  visit_record;

#26.Show visit dates along with hospital and patient name.
select vr.visitdate,h.hospitalname,p.name
from visit_record vr
join hospital_master h on vr.HospitalID=h.HospitalID
join patient_master p on vr.PatientID=p.PatientID;

#27.Show all hospitals that treat more than 3 diseases.
select h.hospitalname,count(dhm.disease) from hospital_master h
join disease_hospital_map dhm on dhm.Specialization=h.Specialization
group by h.hospitalname
having count(dhm.disease) >= 2 ;

#28.List patients who visited a specific hospital.
select p.name,h.hospitalname from visit_record vr
join patient_master p on vr.patientID=p.patientID
join hospital_master h on h.hospitalID=vr.hospitalID
where h.hospitalname = 'hospital_20' ;

#29.Show all patient's latest visit.
select * from patient_master p 
join visit_record vr on p.patientID=vr.patientID
order by vr.VisitDate desc limit 10;

#30.Count number of patients by gender.
select gender,count(patientID) from patient_master
group by gender;

#31.Show all patients who have not visited any hospital (LEFT JOIN)
select p.patientID,count(vr.visitID) from visit_record vr
left join patient_master p
on vr.patientID=p.patientID
group by p.patientID
having count(vr.visitID) = 0;

#32.Show hospitals without any visits.
select h.hospitalname,count(vr.visitID) from visit_record vr
join hospital_master h
on vr.HospitalID=h.HospitalID
group by h.hospitalname
having count(vr.visitID) = 0;

#33.Show total visits per hospital.
select h.hospitalname,count(vr.visitID) from visit_record vr
join hospital_master h 
on vr.HospitalID=h.HospitalID
group by  h.hospitalname;

#34.Show records of patients aged between 20 and 40.
select * from patient_master
where age between 20 and 40;

#35.Find hospitals in each city (GROUP BY city).
select city,count(*) from hospital_master
group by city;

#ADVANCED LEVEL
#36.Show top 3 hospitals for each disease (WINDOW FUNCTION).
select* from (select d.disease,h.hospitalname,
row_number() over(partition by d.disease order by h.rating desc) as top from disease_hospital_map d
join hospital_master h
on d.Specialization=h.Specialization) as t
where top <= 3;

#37.Show total revenue earned by each hospital.
select h.hospitalname,sum(vr.totalbill) from visit_record vr
join hospital_master h
on vr.HospitalID=h.HospitalID
group by h.hospitalname;

#38.Find which hospital has the maximum number of visits.
select h.hospitalname,count(vr.visitID) from visit_record vr
join hospital_master h on vr.hospitalID=h.hospitalID
group by h.hospitalname
order by count(vr.visitID) desc limit 1;

#39.Find which hospital earns the highest revenue.
select h.hospitalname,sum(vr.totalbill) from visit_record vr
join hospital_master h on vr.hospitalID=h.hospitalID
group by h.hospitalname
order by sum(vr.totalbill) desc limit 1;

#40.Find the average bill amount per disease.
select p.disease,avg(vr.totalbill)from visit_record vr
join patient_master p
on vr.patientID=p.patientID
group by p.disease;

#41.Show patient’s full visit history with hospital rating.
select v.*,p.name,h.rating from visit_record v
join patient_master p
on p.PatientID=v.PatientID;

#42.Detect patients who visited multiple hospitals.
select patientID,count(hospitalID) from visit_record
group by patientID
order by count(hospitalID) desc limit 1;

#43.For each city, show the best-rated hospital.
select * from (select city,hospitalname,rating,
row_number() over(partition by city order by rating desc) as top from hospital_master) as t
where top = 1;

#44.Show diseases ranked by number of patients (RANK()).
select disease,count(patientID) as total_potients,
rank() over(order by count(patientID) desc) as top_rank from patient_master
group by disease; 

#45.Show hospitals ranked by revenue.
select hospitalname,sum(totalbill),
rank() over(order by sum(totalbill) desc) as ranks from visit_record v
join hospital_master h 
on v.HospitalID=h.HospitalID
group by hospitalname;

#46.Show patient count growth month-wise (DATE functions).
select month(visitdate),count(patientID) from visit_record
group by month(visitdate)
order by month(visitdate);

#47.Find which specialization has the highest rated hospitals.
select Specialization,max(rating) from hospital_master
group by Specialization
order by max(rating) desc limit 1;

#48.Show the hospital that treats most diseases, with count.
select hospitalname,count(disease) from hospital_master h
join disease_hospital_map d
on h.Specialization=d.Specialization
group by hospitalname
order by count(disease) desc limit 1;

#49.Identify patients who always visit the same hospital.
select v.patientID,count(v.visitID) from visit_record v
join hospital_master h
on v.HospitalID=h.HospitalID
group by h.hospitalname,v.patientID;

#50.Create a VIEW that shows patient name, hospital name, visit date, bill amount.
create view patient_detail as
select p.name,h.hospitalname,v.visitdate,v.totalbill
from visit_record v
join hospital_master h
on v.HospitalID=h.HospitalID
join patient_master p
on v.PatientID=p.PatientID;





