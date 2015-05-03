package Crypt::HSXKPasswd::Util;

# import required modules
use strict;
use warnings;
use Carp; # for nicer 'exception' handling for users of the module
use English qw( -no_match_vars ); # for more readable code
use Crypt::HSXKPasswd;

# Copyright (c) 2015, Bart Busschots T/A Bartificer Web Solutions All rights
# reserved.
#
# Code released under the FreeBSD license (included in the POD at the bottom of
# this file)

#==============================================================================
# Code
#==============================================================================

#
# 'Constants'------------------------------------------------------------------
#

# version info
use version; our $VERSION = qv('1.1_01');

# utility variables
my $_CLASS = 'Crypt::HSXKPasswd::Util';
my $_MAIN_CLASS = 'Crypt::HSXKPasswd';

#
# --- Static Class Functions --------------------------------------------------
#

#####-SUB-#####################################################################
# Type       : CLASS
# Purpose    : Generate a Dictionary module from a text file. The function
#              prints the code for the module.The function prints the code for
#              the module.
# Returns    : VOID
# Arguments  : 1) the name of the module to generate (not including the
#                 HSXKPasswd::Dictionary part)
#              2) the path to the dictionary file
# Throws     : Croaks on invalid args or file IO error
# Notes      : This function can be called as a perl one-liner, e.g.
#              perl -MCrypt::HSXKPasswd::Util -e 'Crypt::HSXKPasswd::Util->dictionary_from_text_file("DefaultDictionary", "sample_dict.txt")' > Crypt/HSXKPasswd/DefaultDictionary.pm
# See Also   :
sub dictionary_from_text_file{
    my $class = shift;
    my $name = shift;
    my $file_path = shift;
    
    # validate args
    unless($class && $class eq $_CLASS){
        $_MAIN_CLASS->_error('invalid invocation of class method');
    }
    unless($name && $name =~ m/^[a-zA-Z0-9_]+$/sx){
        $_MAIN_CLASS->error('invalid module name');
    }
    unless($file_path && -f $file_path){
        $_MAIN_CLASS->error('invalid file path');
    }
    
    # try load the words from the file
    my @words = ();
    eval{
        # slurp the file
        open my $WORDS_FH, '<', $file_path or croak("Failed to open $file_path with error: $OS_ERROR");
        my $words_file_contents = do{local $/ = undef; <$WORDS_FH>};
        close $WORDS_FH;
        
        # process the content
        my @lines = split /\n/sx, $words_file_contents;
        WORD_FILE_LINE:
        foreach my $line (@lines){
            # skip comment lines
            next if $line =~ m/^[#]/sx;
            
            # skip non-word lines
            next unless $line =~ m/^[[:alpha:]]+$/sx;
            
            # save work
            push @words, $line;
        }
        
        # ensure there are at least some words
        unless(scalar @words){
            croak("no valid words found in the file $file_path");
        }
        
        1; # ensure truthy evaluation on successful execution
    }or do{
        $_MAIN_CLASS->_error("failed to load words with error: $EVAL_ERROR");
    };
    
    # generate the code for the class
    my $pkg_code = <<"END_MOD_START";
package ${_MAIN_CLASS}::Dictionary::$name;

use parent ${_MAIN_CLASS}::Dictionary;

# Auto-generated by ${_MAIN_CLASS}::Util->dictionary_from_text_file()
use strict;
use warnings;
use Carp; # for nicer 'exception' handling for users of the module
use English qw( -no_match_vars ); # for more readable code

#
# --- 'Constants' -------------------------------------------------------------
#

# version info
use version; our \$VERSION = qv('1.1_01');

# utility variables
my \$_CLASS = '${_MAIN_CLASS}::Dictionary::$name';

# the word list
my \@_WORDS = (
END_MOD_START

    # print the code for the word list
    foreach my $word (@words){
        $pkg_code .= <<"WORD_END";
    '$word',
WORD_END
    }

    $pkg_code .= <<"END_MOD_END";
);

#
# --- Constructor -------------------------------------------------------------
#

#####-SUB-#####################################################################
# Type       : CONSTRUCTOR (CLASS)
# Purpose    : Create a new instance of class ${_MAIN_CLASS}::Dictionary::$name
# Returns    : An object of class ${_MAIN_CLASS}::Dictionary::$name
# Arguments  : NONE
# Throws     : NOTHING
# Notes      :
# See Also   :
sub new{
    my \$class = shift;
    my \$instance = {};
    bless \$instance, \$class;
    return \$instance;
}

#
# --- Public Instance functions -----------------------------------------------
#

#####-SUB-#####################################################################
# Type       : INSTANCE
# Purpose    : Return the word list.
# Returns    : An Array Ref
# Arguments  : NONE
# Throws     : NOTHING
# Notes      :
# See Also   :
sub word_list{
    my \$self = shift;
    
    return [\@_WORDS];
}
END_MOD_END
    
    # print out the generated code
    print $pkg_code;
}