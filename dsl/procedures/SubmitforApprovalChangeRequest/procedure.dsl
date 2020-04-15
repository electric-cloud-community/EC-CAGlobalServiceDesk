// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Submit for Approval Change Request', description: '''This procedure Submit for Approval change request''', {

    step 'Submit for Approval Change Request', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/SubmitforApprovalChangeRequest/steps/SubmitforApprovalChangeRequest.pl").text
        // TODO altered shell
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }

    formalOutputParameter 'restResult',
        description: 'Rest Call Result'
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: 2c4f0cedbb3dfd529da19f8b3ee7396e ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}