use Modern::Perl;

return {
    bug_number => "30327",
    description => "Add ComponentSortField and ComponentSortOrder sysprefs",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('ComponentSortField','title','call_number|pubdate|acqdate|title|author','Specify the default field used for sorting','Choice'),
            ('ComponentSortOrder','asc','asc|dsc|az|za','Specify the default sort order','Choice')
        });
        say $out "Added ComponentSortField and ComponentSortOrder sysprefs";
    },
};
