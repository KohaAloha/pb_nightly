#!/usr/bin/perl

#
# Copyright 2012 Bywater Solutions
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use C4::CourseReserves qw( GetCourse GetCourseReserve GetCourseReserves );

my $cgi = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "opac-course-details.tt",
        query           => $cgi,
        type            => "opac",
        authnotrequired => 1,
    }
);

my $course_id = $cgi->param('course_id');

die("No course_id given") unless ($course_id);

my $course = GetCourse($course_id);
my $course_reserves = GetCourseReserves( course_id => $course_id, include_items => 1, include_count => 1 );

if ( C4::Context->preference('UseRecalls') ) {
    foreach my $cr ( @$course_reserves ) {
        if ( $cr->{issue}->{date_due} and $cr->{issue}->{borrowernumber} and $borrowernumber != $cr->{issue}->{borrowernumber} ) {
            $cr->{course_item}->{avail_for_recall} = 1;
            $cr->{course_item}->{biblionumber} = Koha::Items->find( $cr->{itemnumber} )->biblionumber;
        }
    }
}

$template->param(
    course          => $course,
    course_reserves => $course_reserves,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
