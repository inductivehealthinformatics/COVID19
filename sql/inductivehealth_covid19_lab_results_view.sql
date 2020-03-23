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

SELECT jur.code_desc_txt                                      AS 'Jurisdiction_Description_Text', 
       pers.local_id                                          AS 'Patient_ID', 
       p_name.last_nm                                         AS 'Last_Name', 
       p_name.middle_nm                                       AS 'Middle_Name', 
       p_name.first_nm                                        AS 'First_Name', 
       Datediff(year, pers.birth_time, o.effective_from_time) AS 'Age_At_Time_Of_Test', 
       pers.age_reported                                      AS 'Age_Reported', 
       pers.age_reported_unit_cd                              AS 'Age_Unit_Cd', 
       pers.birth_time                                        AS 'Birth_Time', 
       tele.phone_nbr_txt                                     AS 'Phone_Number', 
       postal.street_addr1                                    AS 'Address_One', 
       postal.street_addr2                                    AS 'Address_Two', 
       postal.zip_cd                                          AS 'ZipCd', 
       postal.state_cd                                        AS 'StateCd', 
       o.local_id,
       o.cd                                                   AS 'Ordered_Test_Cd', 
       o.cd_desc_txt                                          AS 'Ordered_Test_Desc', 
       o.prog_area_cd                                         AS 'Program_Area', 
       o.jurisdiction_cd                                      AS 'Jur', 
       o.program_jurisdiction_oid,
       mart.cd                                                AS 'Specimen_Cd', 
       mart.cd_desc_txt                                       AS 'Specimen_Desc', 
       ei.root_extension_txt                                  AS 'Specimen_Id', 
       o.add_time                                             AS 'Date_Lab_Added', 
       o.last_chg_time                                        AS 'Date_Lab_Update', 
       o.effective_from_time                                  AS 'Specimen_Coll_Dt', 
       nm.nm_txt                                              AS 'Reporting_Facility', 
       o1.cd                                                  AS 'Resulted_Test_Cd', 
       o1.cd_desc_txt                                         AS 'Resulted_Test_Desc', 
       ovc.code                                               AS 'Result_Code', 
       ovc.code_system_cd                                     AS 'Result_Code_Sys', 
       ovc.display_name                                       AS 'Result_Desc', 
       phc.local_id                                           AS 'Associated_Case_ID', 
          org2.display_nm                                                                 AS 'Ordering_Facility_Desc',
          ovt.value_txt                                                                   AS 'Result_String',
          prv1.first_nm                                                                   AS 'Provider_First_Name',
          prv1.last_nm                                                                           AS 'Provider_Last_Name'

FROM   nbs_odse..observation o 
       INNER JOIN nbs_odse..participation p 
               ON o.observation_uid = p.act_uid 
                  AND p.type_cd = 'AUT' 

       INNER JOIN nbs_odse..organization_name NM 
               ON P.subject_entity_uid = NM.organization_uid 
       INNER JOIN nbs_odse..act_relationship ar 
               ON o.observation_uid = ar.target_act_uid 
                  AND ar.type_cd = 'COMP' 
       INNER JOIN nbs_odse..observation o1 
               ON ar.source_act_uid = o1.observation_uid 
       LEFT OUTER JOIN nbs_odse..obs_value_coded ovc 
                    ON o1.observation_uid = ovc.observation_uid  
       LEFT OUTER JOIN nbs_odse..obs_value_txt ovt  
            ON o1.observation_uid = ovt.observation_uid  
                  AND ovt.txt_type_cd = 'O' 
       INNER JOIN nbs_odse..participation part_2 
               ON o.observation_uid = part_2.act_uid 
                  AND part_2.type_cd = 'PATSBJ' 
       LEFT JOIN nbs_odse..person pers 
              ON part_2.subject_entity_uid = pers.person_uid 
       LEFT JOIN nbs_odse..person_name p_name 
              ON part_2.subject_entity_uid = p_name.person_uid 
                 AND part_2.type_cd = 'PATSBJ' 
                 AND p_name.status_cd = 'A' 
       LEFT JOIN nbs_odse..entity_locator_participation entity_part_tele 
              ON entity_part_tele.entity_uid = pers.person_uid 
                 AND entity_part_tele.class_cd = 'TELE' 
       LEFT JOIN nbs_odse..entity_locator_participation entity_part_postal 
              ON entity_part_postal.entity_uid = pers.person_uid 
                 AND entity_part_postal.class_cd = 'PST' 
       LEFT JOIN nbs_odse..tele_locator tele 
              ON tele.tele_locator_uid = entity_part_tele.locator_uid 
                 AND entity_part_tele.class_cd = 'TELE' 
       LEFT JOIN nbs_odse..postal_locator postal 
              ON entity_part_postal.locator_uid = postal.postal_locator_uid 
                 AND entity_part_postal.class_cd = 'PST' 
       LEFT JOIN nbs_odse..participation part3 
              ON o.observation_uid = part3.act_uid 
                 AND part3.type_cd = 'SPC' 
       LEFT JOIN nbs_odse..material mart 
              ON part3.subject_entity_uid = mart.material_uid 
       LEFT JOIN nbs_odse..entity_id ei 
              ON mart.material_uid = ei.entity_uid 
                 AND ei.type_cd = 'SPC' 
                 AND ei.assigning_authority_id_type = 'CLIA' 
       LEFT JOIN nbs_odse..act_relationship ar2 
              ON ar2.source_act_uid = o.observation_uid 
       LEFT JOIN nbs_odse..public_health_case phc 
              ON phc.public_health_case_uid = ar2.target_act_uid 
       LEFT JOIN nbs_srte..jurisdiction_code jur 
              ON jur.code = o.jurisdiction_cd
          LEFT JOIN NBS_ODSE..Participation part4  
                      ON o.observation_uid = part4.act_uid 
                           AND part4.type_cd = 'ORD' 
                           AND part4.subject_class_cd = 'ORG' 
          LEFT JOIN NBS_ODSE..Organization org2 
                      ON part4.subject_entity_uid = org2.organization_uid

          LEFT JOIN NBS_ODSE..Participation part5
                      ON o.observation_uid = part5.act_uid 
                           AND part5.type_cd = 'ORD' 
                           AND part5.subject_class_cd = 'psn' 
                           
          LEFT JOIN NBS_ODSE..Person prv1 
                      ON part5.subject_entity_uid = prv1.person_uid       
                       AND prv1.status_cd = 'A'

WHERE  o.obs_domain_cd_st_1 = 'Order' 
       AND o.ctrl_cd_display_form = 'LabReport' 
       AND o.cd IN ( '94309-2', '39433', '94500-6', 
                     '94533-7', '94534-5', '94532-9', '94502-2', 
                     '94507-1', '94505-5', '94508-9', '94506-3', 
                     '94547-7', '94531-1', '94306-8', '94503-0', 
                     '94504-8','SCV2A','3002640', '3002638', '3002658', '39444') 
       AND o.add_time > '2020-02-10 00:01:00.070' 

GO