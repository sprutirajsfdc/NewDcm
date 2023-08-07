/**
@Description			: This class assigns cases to different shift queues based on custom-defined shift times.
@Author					: Surendranath Reddy, Subba Reddy Venkata, Sprutiraj Panda, Sravani Bandaru
@Last Modified By		: Subba Reddy, Surendranath Reddy
@Last Modified On		: 20/04/2023
@Modification Log		:
Ver					Date						Author								LastModification
1.0					26/04/2023					Surendranath Reddy					Initial Version
												Subba Reddy Venkata
**/
public class AssignCasetoShiftQueue {
    // Define a private static method named "parseTime" that accepts a String parameter "timeValue" and returns a Time object.
    private static Time parseTime(String timeValue) {
        // Split the input "timeValue" string using the colon (':') separator and store the resulting substrings in the "strTimeSplit" array.
        String[] strTimeSplit = timeValue.split(':');
        // Create a new Time instance using the hour and minute values parsed from the "strTimeSplit" array.
        // The seconds and milliseconds are set to zero.
        Time timeChange = Time.newInstance(Integer.valueOf(strTimeSplit[0]), Integer.valueOf(strTimeSplit[1]), 0, 0);
        // Return the created Time object.
        return timeChange;
    }
    
    
    
    // Assign cases to shift queues based on certain conditions
    public static void casetoshiftqueue(list<case> caseList){
        // Get the shift times from custom settings
        ShiftTime__c shiftTimes = ShiftTime__c.getInstance();
        // Parse the shift start and end times
        Time shift1StartTime = parseTime(shiftTimes.Shift1StartTime__c);
        Time shift1EndTime = parseTime(shiftTimes.Shift1EndTime__c);
        Time shift2StartTime = parseTime(shiftTimes.Shift2StartTime__c);
        Time shift2EndTime = parseTime(shiftTimes.Shift2EndTime__c);
        Time shift3StartTime = parseTime(shiftTimes.Shift3StartTime__c);
        Time shift3EndTime = parseTime(shiftTimes.Shift3EndTime__c);
        // Iterate over each Case record in the "caseList"
                        Time currentTime = Time.newInstance(
                    Datetime.now().hour(),
                    Datetime.now().minute(),
                    Datetime.now().second(),
                    0
                );
        id queueownerid;
        string shiftname;
        if (currentTime >= shift1StartTime && currentTime <= shift1EndTime) { 
                    // Assign to morning shift queue
                    queueownerid= [SELECT Id FROM Group WHERE Type = 'Queue' AND Name ='Morning Shift'].Id;
                    shiftname= 'Morning Shift';
                    //System.debug('c.OwnerId' + c.OwnerId);
                    // Check if the current time falls within Shift 2 time range
                } else if (currentTime >= shift2StartTime && currentTime <= shift2EndTime) { 
                    // Assign to afternoon shift queue
                    queueownerid= [SELECT Id FROM Group WHERE Type = 'Queue' AND Name ='Afternoon Shift'].Id;
                    shiftname= 'Afternoon Shift';
                    //System.debug('c.OwnerId' + c.OwnerId);
                } else {
                    // Assign to night shift queue
                    queueownerid= [SELECT Id FROM Group WHERE Type = 'Queue' AND Name ='Night Shift'].Id;
                    shiftname= 'Night Shift';
                    //System.debug('c.OwnerId' + c.OwnerId);
                }
                list<id>list_ofuseridinqueue=new list<id>();
                list<GroupMember>u=[SELECT id,UserOrGroupId from GroupMember where Group.id =:queueownerid];
                for(GroupMember u1:u){
                    system.debug('aa'+u1.UserOrGroupId);
                    list_ofuseridinqueue.add(u1.UserOrGroupId);
                }
                
                id assigningid;
                case cc=[select id,Assigned_to__c from case order by createddate desc limit 1 ];
                  if(cc ==null){
                    assigningid=list_ofuseridinqueue[0];
                }else{
                    integer indexofpreassignmentid=list_ofuseridinqueue.indexof(cc.Assigned_to__c);//id

                    integer indexofpreassignmentidadd=indexofpreassignmentid+1;
                    if(list_ofuseridinqueue.size()==indexofpreassignmentidadd){
                     assigningid=list_ofuseridinqueue[0];   
                    }else{
                       assigningid=list_ofuseridinqueue.get(indexofpreassignmentidadd);
                    }

                }
        for (Case c : caseList) {
            // Check if the Case meets the conditions: Priority is 'Low' or 'Medium', Skill Name and Product are null
            if((c.Priority == 'Low' || c.Priority == 'Medium') && c.Skill_Name__c == null && c.Product__c == null){
                // Get the current time
              
                // Check if the current time falls within Shift 1 time range
                
                c.Assigned_to__c=assigningid;
                c.OwnerId=queueownerid;
                c.Initial_Shift_Name__c=shiftname;
            }
        //}
    }
}
}