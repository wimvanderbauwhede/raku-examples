#### OBJECTS, TYPES, ENUMS ####
use v6;

enum InclType <External Common  Both None>; # Shorthand for a map from Str to Int
enum NodeName <Comment Var Param Assignment Do EndDo If EndIf>;

=begin compare

var InclType = {
  External: 1,
  Common: 2,
  Parameter: 3,
};

from enum import Enum
class InclType(Enum):
    External = 1
    Common = 2
    Parameter = 3


=end compare

class Info {
    has %.Tags; 
    has $.LineID;
    has $.Deleted;
    method hasTags ($f) { 
        for self.Tags.keys -> $t {
            if ($f($t)) { 
                return True
            }
        }
        return False
    }
}

class AnnLine {
    has $.Line;
    has $.Info;
}

class VarDecl is Decl {
    has $.IODir;
}


class Info {
    has %.Tags; 
    has Int $.LineID;
    has Bool $.Deleted is rw;
    method hasTags (Sub $f --> Bool) { 
        for self.Tags.keys -> $t {
            if ($f($t)) { 
                return True
            }
        }
        return False
    }
}

=begin compare
// JavaScript
var Info = {
    Tags: {},
    LineId: 0,
    Deleted: false,
    hasTags(f) { 
        for (t in this.Tags) {
            if(f(t)) {
                return true;
            }
        }
        return false;
    },
}

# Python

class Info:
     def __init__(self, tag, lineID, deleted):
         self.Tags = tag
         self.LineId = lineId
         self.Deleted = deleted
    def hasTags (self,f):
        for t in self.Tags:
            if f(t):
                return True
        return False

class VarDecl(Decl):
    IODir = 'Unknown' # No way to force this to be an enum


=end compare


class AnnLine {
    has Str $.Line;
    has Info $.Info;
}

class SourceFile {
    has Str $.Name;
    has AnnLine @.AnnLines;

}
class IncludeFile is SourceFile {
    has InclType $.InclType;
}

class Subroutine is SourceFile {

}

class Decl {
    has Str $.Name;
    has $.Type; 
    has Str $.Indent;
    has @.Attr;
    has Int @.Dim;
    has Int $.Status is rw;
}

enum IODir <In Out InOut Unknown>;

class VarDecl is Decl {
    has IODir $.IODir is rw;
}

class ParamDecl is Decl {
    has Numeric $.Val;
}

class State {
    has Str $.Top;
    has IncludeFile %.IncludeFiles;
    has Subroutine %.Subroutines;
}

sub init_state (Str $subname) returns State {

    my $state = State.new(
        Top          => $subname,
        IncludeFiles => {'inc1' => IncludeFile.new(
                Name => 'inc1', InclType => Common,
                AnnLines => [
                    AnnLine.new(Info => Info.new(Tags => { Comment => '! Comment '})
                )
            ]), 
            'inc2' => IncludeFile.new(Name => 'inc2')},
        Subroutines  => {'sub1' => Subroutine.new(Name => 'sub1')}
    );
        
    return $state;
}

my State $stref = init_state('main');
say $stref.perl;
say $stref.IncludeFiles<inc1>.AnnLines[0].Info.Tags{Comment};
#$stref.IncludeFiles<inc1>.AnnLines[0].Info.Tags{Comment}='';
$stref.IncludeFiles<inc1>.AnnLines[0].Info.Tags{Var}=VarDecl.new(Name=>'v', IODir=>InOut, Type=>'real(kind=4)');
my $info = $stref.IncludeFiles<inc1>.AnnLines[0].Info;
say $info.Tags.perl;
say $info.hasTags( sub (Str $x --> Bool) { $x eq Comment ?? True !! False });

