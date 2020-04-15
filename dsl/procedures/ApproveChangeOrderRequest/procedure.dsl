// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Approve Change Order Request', description: '''This procedure Approve change order request''', {

    step 'Approve Change Order Request', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/ApproveChangeOrderRequest/steps/ApproveChangeOrderRequest.pl").text
        // TODO altered shell
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }

    formalOutputParameter 'restResult',
        description: 'Rest Call Result'
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: 1ec539e728039fe70101b9e5b20af863 ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}