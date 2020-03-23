/**
Created by InductiveHealth Informatics
Date Created:  3/21/2020 3:00 PM ET
Author:  Stephen Macauley, InductiveHealth Informatics
Proprietary and Confidential – Copyright: InductiveHealth Informatics, Inc. 2020.  Provided for use by commonwealth, state, and territorial health departments to support their COVID-19 response using the NEDSS Base System (NBS).
**/

USE [NBS_ODSE]
GO
 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[inductive_covid19_contacts] as
select
        p.local_id as 'Contact_Person_ID',
        substring (p.local_id,6,6) as 'Contact_Person_ID2',
        p_name.first_nm as 'Contact_NameF',
        p_name.last_nm as 'Contact_NameL',
        p_name.middle_nm as 'Contact_NameM',
        p.ethnic_group_ind as 'Contact_Ethn',
        p.age_reported AS 'Contact_Age_Reported',
        p.age_reported_unit_cd AS 'Contact_Age_Unit_Cd',
        p.birth_time AS 'Contact_Birth_Time',
        p.curr_sex_cd as 'Contact_Sex',
        postal.street_addr1 as 'Contact_Street1',
        postal.street_addr2 as 'Contact_Street2',
        postal.state_cd as 'Contact_State',
        postal.city_cd as 'Contact_City',
		postal.cntry_desc_txt as 'Contact_County',
		postal.cnty_desc_txt as 'Contact_County_Desc',
        postal.city_desc_txt as 'Contact_City_Desc',
		postal.zip_cd as 'Contact_Zip',
        p2.first_nm as 'Patient_FName',
        p2.last_nm as 'Patient_LName',
        phc.local_id as 'Patient_PHC_ID',
        phc.cd as 'Patient_PHC_CD',
        phc.cd_desc_txt as 'Patient_PHC_Desc',
        phc.add_time 'Patient_PHC_Add_Time',
        phc.last_chg_time as 'Patient_PHC_Chg_Time',
        phc.txt as 'Patient_PHC_Notes',
        phc.investigation_status_cd as 'Patient_PHC_Status',
        phc.case_class_cd as 'Patient_PHC_Class_Cd',
        phc.infectious_from_date as 'Patient_PHC_Infect_From',
        phc.infectious_to_date as 'Patient_PHC_Infect_To',
        ct.local_id as 'Contact_ID',
        ct.add_time as 'Contact_Add_Time',
        ct.last_chg_time as 'Contact_Chg_Time',
        ct.prog_area_cd as 'Contact_Prog_Area_CD',
        ct.jurisdiction_cd as 'Contact_Jur_CD',
        jur.code_desc_txt as 'Contact_Jur_Desc_CD',
        ct.program_jurisdiction_oid,
        ct.contact_status as 'Contact_Status',
        ct.priority_cd as 'Contact_Priority',
        ct.group_name_cd as 'Contact_GroupName',
        ct.investigator_assigned_date as 'Contact_Invstr_Date',
        ct.disposition_cd as 'Contact_Dispo_CD',
        ct.disposition_date as 'Contact_Dispo_Date',
        ct.named_on_date as 'Contact_Named_Date',
        ct.relationship_cd as 'Contact_Rel_Cd',
        ct.health_status_cd as 'Contact_HealthStatus',
        ct.txt as 'Contact_Notes',
        ct.symptom_cd as 'Contact_Sypm',
        ct.symptom_onset_date as 'Contact_Sypm_Onset',
        ct.symptom_txt as 'Contact_Sypm_Txt',
        ct.risk_factor_cd as 'Contact_RiskFactor',
        ct.risk_factor_txt as 'Contact_RiskFactor_Txt',
        ct.evaluation_completed_cd as 'Contact_Eval_Comp',
        ct.evaluation_date as 'Contact_Eval_Date',
        ct.evaluation_txt as 'Contact_Eval_Txt',
        ct.treatment_initiated_cd as 'Contact_Tx_Init',
        ct.treatment_start_date as 'Contact_Tx_Start',
        ct.treatment_not_start_rsn_cd as 'Contact_Not_Start',
        ct.treatment_end_cd as 'Contact_Tx_End',
        ct.treatment_end_date as 'Contact_Tx_End_Date',
        ct.treatment_not_end_rsn_cd as 'Contact_Not_End',
        ct.treatment_txt as 'Contact_Tx_Txt',
        ct.contact_referral_basis_cd as 'Contact_Referal_Basis',
        p3.first_nm as 'Contact_Invstr_FName',
        p3.last_nm as 'Contact_Invstr_LName',
        phc2.local_id as 'Contact_Inv_LocalID',
        phc2.cd as 'Contact_Cond_Cd',
        phc2.cd_desc_txt as 'Contact_Cond_Desc'
    from
        nbs_odse..CT_contact ct
    inner join
        nbs_odse..Public_health_case phc
            on ct.subject_entity_phc_uid = phc.public_health_case_uid
    inner join
        nbs_odse..Person p
            on ct.contact_entity_uid = p.person_uid
    inner join
        nbs_odse..person p2
            on ct.subject_entity_uid = p2.person_uid
    left outer join
        nbs_odse..Public_health_case phc2
            on ct.contact_entity_phc_uid = phc2.public_health_case_uid
    left outer join
        nbs_odse..NBS_act_entity nae
            on ct.ct_contact_uid = nae.act_uid
            and nae.type_cd = 'InvestgrOfContact'
    left outer join
        nbs_odse..person p3
            on nae.entity_uid = p3.person_uid      
     
    LEFT JOIN
        nbs_odse..entity_locator_participation entity_part_postal               
            ON entity_part_postal.entity_uid = ct.contact_entity_uid                  
            AND entity_part_postal.class_cd = 'PST'        
    
    LEFT JOIN
        nbs_odse..postal_locator postal               
            ON entity_part_postal.locator_uid = postal.postal_locator_uid                  
            AND entity_part_postal.class_cd = 'PST'    
  
    LEFT JOIN nbs_odse..person_name p_name
              ON ct.contact_entity_uid = p_name.person_uid
                 AND p_name.status_cd = 'A'      
     LEFT JOIN nbs_srte..jurisdiction_code jur
              ON jur.code = ct.jurisdiction_cd
    WHERE
        phc.cd = '11065'
GO