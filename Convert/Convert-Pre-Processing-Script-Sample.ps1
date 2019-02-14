﻿param($provider)

# -------------------------------------------------------
# Helper functions - see below for the MAIN code
# -------------------------------------------------------

# 
# dump all available script metadata
#
function Cinegy-DumpProviderMetadata($provider, $logger)
{
    #log message about function start
    $logger.Info(" == Cinegy-DumpProviderMetadata == ")

    # ensure provider is ready to serve files list
    if ([bool]($provider.PSObject.Methods.Name -match "QueryFiles"))
    {
        # get the list of files created
        # NOTE: in general case the task can have multiple targets that can have multiple output destinations
        # therefore we loop through all returned items. In the simple case there will be just one file in the list
        $files = $provider.QueryFiles();

        $logger.Info("Files:")
        foreach($fileMetadataSet in $files)
        {
            # each returned file set can have multiple properties, output all of them
            foreach($fileMateadata in $fileMetadataSet.GetEnumerator())
            {
                $logger.Info("  $($fileMateadata.Key): $($fileMateadata.value)")
            }
        }
    }

    # dump all available metadata items for the task
    $logger.Info("Metadata:")
    foreach($metadata in $provider.Metadata.GetEnumerator())
    {
        $logger.Info("  $($metadata.Key): $($metadata.value)")
    }

    $logger.Info(" ==== ")
}

# 
# Add custom metadata to be used as macro
#
function Cinegy-AddSampleMetadata($provider, $logger)
{
    #log message about function start
    $logger.Info(" == Cinegy-AddSampleMetadata == ")

    # define custom metadata item - can be referenced in the profile as {src.meta.custom-metadata}
    $customMetadata = "Custom metadata: some value by Cinegy Convert"
    $provider.AddMetadata('src.meta.custom-metadata', $customMetadata)	
    $logger.Info("    new custom metadata {src.meta.custom-metadata} = '$customMetadata'")

    # calculate MD5 has for the source file - can be referenced in the profile as {src.meta.custom-file-MD5}
    # NOTE: assuming that source is media file and location + name + extension are defines correctly in .CineLink
    $fileName = $provider.Metadata['src.name']
    $fileExt = $provider.Metadata['src.ext']
    $fileLocation = $provider.Metadata['src.location']

    $filePath = [io.path]::combine($fileLocation, $fileName + $fileExt)
    $logger.Info("    Calculating MD5 hash for the source file '$filePath'")
    $hash = (Get-FileHash $filePath -Algorithm MD5).Hash.ToUpper()
    $provider.AddMetadata('src.meta.custom-file-MD5', $hash)
    $logger.Info("    new custom metadata {src.meta.custom-file-MD5} = '$hash'")

    $logger.Info(" ==== ")
}


# -------------------------------------------------------
# MAIN
# -------------------------------------------------------

# get logger instance to add information directly into task log

$logger = [Cinegy.Logging.ILogger]$provider.Logger
$logger.Info(" === Pre-Processing script - START")

# Sample #1 - define new metadata
Cinegy-AddSampleMetadata $provider $logger

# Sample #2 - dump all available metadata
Cinegy-DumpProviderMetadata $provider $logger



