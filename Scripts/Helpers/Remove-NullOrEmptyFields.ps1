function Remove-NullOrEmptyFields {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        $inputObject,

        [switch] $nullOnly
    )

    if ($null -ne $inputObject) {
        $type = $inputObject.GetType()
        $typeName = $type.Name

        if ($typeName -in @( "Hashtable", "OrderedDictionary", "OrderedHashtable" )) {
            $keys = [System.Collections.ArrayList]::new($inputObject.Keys)
            foreach ($key in $keys) {
                $value = $inputObject.$key
                if (Confirm-NullOrEmptyValue $value -nullOnly $nullOnly) {
                    $null = $inputObject.Remove($key)
                }
            }
            foreach ($value in $inputObject.Values) {
                $type = $value.GetType()
                $typeName = $type.Name
                if ($typeName -in @( "Object[]", "ArrayList", "Hashtable", "OrderedDictionary", "OrderedHashtable" ) -or $value -is [PSCustomObject]) {
                    Remove-NullOrEmptyFields $value -nullOnly:$nullOnly
                }
            }
        }
        elseif ($typeName -in @( "Object[]", "ArrayList" )) {
            foreach ($value in $inputObject) {
                $type = $value.GetType()
                $typeName = $type.Name
                if ($typeName -in @( "Object[]", "ArrayList", "Hashtable", "OrderedDictionary", "OrderedHashtable") -or $value -is [PSCustomObject]) {
                    Remove-NullOrEmptyFields $value -nullOnly:$nullOnly
                }
            }
        }
        elseif ($inputObject -is [PSCustomObject]) {
            $properties = $inputObject.psobject.properties
            $removeNames = [System.Collections.ArrayList]::new()
            foreach ($property in $properties) {
                $value = $property.Value
                if (Confirm-NullOrEmptyValue $value -nullOnly $nullOnly) {
                    $name = $property.Name
                    $null = $removeNames.Add($name)
                }
            }
            foreach ($removeName in $removeNames) {
                $null = $inputObject.psobject.properties.remove($removeName)
            }
            foreach ($property in $properties) {
                $value = $property.Value
                if ($null -eq $value) {
                    $null = $value
                }
                $type = $value.GetType()
                $typeName = $type.Name

                if ($typeName -in @( "Object[]", "ArrayList", "Hashtable", "OrderedDictionary", "OrderedHashtable") -or $value -is [PSCustomObject]) {
                    Remove-NullOrEmptyFields $value -nullOnly:$nullOnly
                }
            }
        }
    }
}
