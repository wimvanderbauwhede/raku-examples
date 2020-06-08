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

class AnnLine {
    has Str $.Line;
    has Info $.Info;
}

class VarDecl is Decl {
    has IODir $.IODir is rw;
}

