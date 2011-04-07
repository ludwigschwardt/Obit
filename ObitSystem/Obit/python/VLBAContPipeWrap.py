"""
A wrapper for the VLBA Continuum Pipeline. This module can be invoked from the
command line or by calling the function pipeWrap directly.

External Dependencies:

* Requires python 2.7 (for logging)
* *diff* -- tested with 'diff (GNU diffutils) 2.8.1'
"""

import os, shutil, sys, logging, logging.config, pprint, subprocess, errno 
import exceptions, pprint, re
from optparse import OptionParser
from urllib2 import URLError, HTTPError
from ConfigParser import NoSectionError
import VLBAContPipe, VLBACal, PipeUtil

try:
    logging.config.fileConfig("logging.conf")
    logger = logging.getLogger("obitLog.VLBAContPipeWrap")
except NoSectionError, e:
    logging.basicConfig(filename="VLBAContPipeWrap.log", level=logging.DEBUG)
    logger = logging
    errmsg = "CANNOT FIND logging.conf. USING BASIC LOGGING CONFIG INSTEAD."
    logger.error( errmsg )
    print( errmsg )

def pipeWrap( startDate, endDate, options ):
    """
A wrapper for the VLBA continuum pipeline, :mod:`VLBAContPipe`. Query archive
and begin processing all datafiles in response. Process each file in a 
unique working directory.

:param string startDate: start of date range for archive query
:param string endDate: end of date range for archive query; if NONE then use 
    startDate
:param optparse.Option options: command line options (returned by 
    :func:`optparse.parse_args`)
    """
    logger.info("Pipeline Wrapper Begins")

    ##### pipeWrap PARAMETERS #####
    aipsSetup      = 'PipeAIPSSetup.py' # pipeline AIPS setup file
    # validation area
    checkDir       = '/lustre/aoc/users/jcrossle/VLBAPipeProducts/check' 
    fitsDir        = '/lustre/aoc/users/jcrossle/fits' # fits download directory
    outfilesPickle = 'outfiles.pickle' # output files pickle
    logConfig      = 'logging.conf' # logging module configuration
    ###############################

    # Send query and print summary
    logger.info("Submitting query to archive")
    responseLines = PipeUtil.QueryArchive( startDate, endDate, options.project )
    fileDictList = PipeUtil.ParseArchiveResponse( responseLines )
    logger.info( "\n" + PipeUtil.SummarizeArchiveResponse( fileDictList ) )
    if options.verbose:
        str1 = pprint.pformat( fileDictList )
        logger.info( "\n" + str1 )
    if options.query: 
        return
    
    # Loop over all files in response, setup working directory and process
    cwd = os.getcwd()
    for i, fileDict in enumerate( fileDictList ):
        logger.info("Preparing to process file (" + str(i+1) + 
                " / " + str( len(fileDictList) ) + "):\n" + 
                pprint.pformat(fileDict))
        try:
            PipeUtil.DownloadArchiveFile( fileDict, fitsDir ) # start download
            # create working subdirectory
            dirName = fileDict['project_code'] + '_' + fileDict['DATE'] + '_' + \
                fileDict['arch_file_id']
            logger.debug("Creating directory " + dirName)
            if not os.path.exists( dirName):
                os.mkdir( dirName )
            else:
                logger.warning("Project working directory exists: " + dirName)
            shutil.copy( aipsSetup, dirName ) # copy AIPSSetup into dir
            # Copy logging config file; set log file name for processing
            newLogConfig = dirName + '/' + logConfig
            newLogName = fileDict['project_code'] + '_' + \
                VLBACal.VLBAGetSessionCode( fileDict ) + '_' + \
                VLBACal.VLBAGetBandLetter( fileDict )[0] + '.log'
            substitute( logConfig, newLogConfig, "VLBAContPipeWrap.log",
                newLogName )
            os.chdir( dirName )
            # create pipeline input parm file
            parmList = VLBACal.VLBAGetParms( fileDict, checkDir )
            parmFile = "VLBAContParm_" + fileDict['project_code'] + '.py'
            VLBACal.VLBAMakeParmFile( parmList, parmFile )
            PipeUtil.PollDownloadStatus( fileDict, fitsDir ) # check that d/l is complete
            # Start the pipeline separate, synchronous process
            logger.info("Starting pipeline processing (file " + str(i+1) + 
                " / " + str( len(fileDictList) ) + ")" )
            cmd = ("python", os.environ['OBIT'] + "/python/VLBAContPipe.py", 
                aipsSetup, parmFile)
            subprocess.check_call( cmd )
            # Copy files to check dir
            projCheckDir = checkDir + '/' + dirName
            copyFiles( outfilesPickle, projCheckDir )
            os.chdir( cwd )
            # if all contents copied, remove working directory; otherwise keep
            if checkDirEquality( dirName, projCheckDir ):
                logger.info("Removing " + dirName)
                shutil.rmtree( dirName ) 
            else:
                logger.error("Not removing " + dirName)
        except HTTPError, e:
            logger.error("Server could not fulfill request. Error code: " + \
                str(e.code))
            raise
        except URLError, e:
            logger.error("Failed to reach the server. Reason: " + str(e.reason))
            raise
        except subprocess.CalledProcessError, e:
            logger.error("A subprocess failed with return code: " + \
                str(e.returncode) )
            raise
        except IOError, e:
            logger.error("File " + e.filename + " not found\n" + \
                "  Cannot copy files to validation directory" )
            raise
    logger.info("Pipeline Wrapper Ends")

def copyFiles( outfilesPickle, destDir='./output' ):
    """
Copy output files to destination directory. This is done using rsync.

* outfilesPickle = name of outfiles pickle file
* destDir = directory to which files should be copied
    """
    # Get a list of all output files
    if not os.path.exists( outfilesPickle ):
        raise exceptions.IOError( errno.ENOENT, "File not found", 
            outfilesPickle )
    outfiles = PipeUtil.FetchObject( outfilesPickle )
    outfilesList = VLBACal.VLBAMakeOutfilesList( outfiles )
    logger.debug("outfilesList = " + str(outfilesList) )
    logger.info( "Copying (rsync-ing) output files to " + destDir )
    # Prepare destination directory
    if not os.path.isdir( destDir ): # not dir
        if os.path.exists( destDir ):  # not dir & exists
            logger.error( 
                "Copy failed: destination exists and is not a directory." )
            raise OSError( errno = errno.ENOTDIR, 
                strerror = "File exists and is not a directory",
                filename = destDir )
        else: # not dir & not exists
            os.makedirs( destDir )
    # Copy files using rsync
    cmd = [ "rsync", "--verbose", "--times" ]
    cmd.extend( outfilesList )
    cmd.append( destDir )
    try:
        subprocess.check_call( cmd )
    except subprocess.CalledProcessError, e:
        logger.error(
            "Error occurred while rsyncing to destination directory.\n" +
            "rsync return value: " + str(e.returncode) )
        raise
 
def checkDirEquality( dir1, dir2 ):
    """
Compare directories given by paths dir1 and dir2.  If the files contained
in the directory are the same, return true.  If any files differ return 
false.

Use system utility diff for directory comparison. diff compares directory
AND file content in one call. This is not easy to do with Python's filecmp
module.

* dir1, dir2 = directories to compare
    """
    logger.info("Comparing contents of work and validation directories.")
    logger.debug("diff will ignore logging.conf")
    cmd = ( "diff", dir1, dir2, "--exclude=logging.conf" )
    returncode = 0
    try:
        subprocess.check_call( cmd )
    except subprocess.CalledProcessError, e:
        returncode = e.returncode
        logger.error(
            "Pipeline working directory and check directory differ.\n"
            "System call to diff returns code: " + str(returncode) )
    if returncode == 0:
        logger.info("Directories equal.")
        return True
    else:
        return False

def substitute( inFile, outFile, str1, str2 ):
    """
Write the contents of inFile to outFile with each instance of str1
replaced with str2.

* inFile = input file
* outFile = output file
* str1 = string to be replaced
* str2 = replacement string
    """
    logger.debug("Writing " + inFile + " to " + outFile + 
        " while replacing " + str1 + " with " + str2 )
    o = open( outFile, "w" )
    data = open( inFile ).read()
    o.write( re.sub( str1, str2, data ) )
    o.close()

if __name__ == "__main__":
    # Get inputs from command line
    usage = "usage: %prog [options] StartDate [StopDate]"
    parser = OptionParser( usage=usage )
    parser.add_option( '-P', '--project', help="project code" )
    parser.add_option( '-q', '--query', action="store_true", default=False, 
        help="query and summary only" )
    parser.add_option( '--verbose', action="store_true", default=False, 
        help="Display entire query response" )
    (options, args) = parser.parse_args()
    if len(args) < 1: 
        logger.critical("Too few arguments given")
        parser.print_help()
        sys.exit()
    elif len(args) == 1:
        pipeWrap( args[0], args[0], options)
    else:
        pipeWrap( args[0], args[1], options)