__author__ = 'Chris Bergh'
import os
import sys
import shutil
import argparse
if not '/dk' in sys.path:
    sys.path.insert(0, '/dk' )
if not '/dk/AnalyticContainer' in sys.path:
    sys.path.insert(0, '/dk/AnalyticContainer')
if not '/dk/AnalyticContainer/AnalyticContainerLibrary' in sys.path:
    sys.path.insert(0, '/dk/AnalyticContainer/AnalyticContainerLibrary')
def dump_env(de):
    if de is True:
        print("DUMPING ENV ...........")
        for key in os.environ.keys():
            print "%s: %s \n" % (key, os.environ[key])
        print("sys.path: %s \n" % sys.path)
        print("os.cwd: %s \n" % os.getcwd())
dump_env(False)
from AnalyticContainer.AnalyticContainerLibrary.ACBase import *

# ---------------------------------------------------------------------------------------------------------------------
# ACExampleOne example container class:
# ---------------------------------------------------------------------------------------------------------------------
class ACExampleOne(ACBase):
    def __init__(self):
        ACBase.__init__(self)


def main(parser=None):
    ac_example1 = ACExampleOne()
    if ac_example1.vaild_config() is True:
        ac_example1.set_progress("progress-1", "1")
        ac_example1.set_progress("progress-2", "2")
        if ac_example1.set_test_results('example-test-name-1', CONTAINER_TEST_ACTION_WARNING,
                                     CONTAINER_TEST_RESULT_PASSED, "example-test-1 != 0") is False or \
            ac_example1.add_test_result_value('example-test-name-1',
                                              CONTAINER_TEST_VALUE_INT, 'example-test-1', 0) is False:
            ACLogger.log_and_print_error('unable to set test results')
            ac_example1.set_container_status(CONTAINER_STATUS_ERROR)

        print '%s' % ac_example1.__str__()
        print 'ACExampleOne: writing progress: %s ' % ac_example1.get_progress()
        if ac_example1.parse_command_line(parser) is True:
            ac_example1.set_container_status(CONTAINER_STATUS_SUCCESS)
            ac_example1.execute()
            ACLogger.log_and_print('...ACExampleOne:  Completed command, exiting')
            # close logger and move ams_logger.log to self.file_mount
            log_filename = AC_LOG_FILE_LOCATION # ACLogger.get_log_filename()
            try:
                shutil.copyfile(log_filename, ac_example1.inside_log_file)
            except IOError:
                ACLogger.log_and_print_error('ACExampleOne: unable to move log file from %s to %s' %
                                              (log_filename, ac_example1.inside_log_file))
        else:
            ACLogger.log_and_print_error('ACExampleOne: Exiting ... invalid command line')
    else:
        ACLogger.log_and_print_error('ACExampleOne: Exiting ... invalid config')
        ac_example1.set_container_status(CONTAINER_STATUS_ERROR)
    ac_example1.write_progress()


if __name__ == "__main__":
    cmdline_parser = argparse.ArgumentParser(description="Welcome to the ACExampleOne Command Line Program")
    main(cmdline_parser)
