// This procedure.dsl was generated automatically
// DO NOT EDIT THIS BLOCK === procedure_autogen starts ===
procedure 'Copy Change Request', description: '''This procedure copy change request''', {

    step 'Copy Change Request', {
        description = ''
        command = new File(pluginDir, "dsl/procedures/CopyChangeRequest/steps/CopyChangeRequest.pl").text
        // TODO altered shell
        shell = 'ec-perl'

        postProcessor = '''$[/myProject/perl/postpLoader]'''
    }

    formalOutputParameter 'referenceNumber',
        description: 'the new reference number that generated.'

    formalOutputParameter 'restResult',
        description: 'Rest Call Result'
// DO NOT EDIT THIS BLOCK === procedure_autogen ends, checksum: 45eba7c040f6c9dfeab5e197dd366d2c ===
// Do not update the code above the line
// procedure properties declaration can be placed in here, like
// property 'property name', value: "value"
}