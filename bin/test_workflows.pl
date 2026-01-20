use strict;
use warnings;
use Test::More;
use YAML;
use File::Path;

my $local = YAML::LoadFile('./.github/workflows/mirror.yml');
my %tags  = map { $_ => 1 } @{ $local->{jobs}{'pull-and-push'}{strategy}{matrix}{tag} // [] };
$tags{centos6} = 1;    # special case

my @branches = qw(develop support-8.8.x support-8.0.x);
my @repos    = qw(movabletype movabletype-addons movabletype-plugins);

my %used;
for my $repo (@repos) {
    for my $branch (@branches) {
        my $tmpdir = "./tmp/$repo/$branch";
        rmtree $tmpdir if -d $tmpdir;
        system("git", "clone", "git\@github.com:movabletype/$repo", "-b", $branch, "--depth", 1, $tmpdir);
        my $yml = "$tmpdir/.github/workflows/movabletype.yml";
        if (!-f $yml) {
            note "$yml is not found";
            next;
        }
        my $workflow = YAML::LoadFile($yml);
        for my $key (keys %{ $workflow->{jobs} }) {
            if (my $image = $workflow->{jobs}{$key}{env}{TEST_IMAGE_NAME}) {
                ok $tags{$image}, "$image is used in $repo/$branch (by env)";
                $used{$image}{$branch} = 1;
            }
            if (my $config = $workflow->{jobs}{$key}{strategy}{matrix}{config}) {
                for my $c (@$config) {
                    my $image = $c->{image} or next;
                    ok $tags{$image}, "$image is used in $repo/$branch (by matrix config)";
                    $used{$image}{$branch} = 1;
                }
            }
            if (my $config = $workflow->{jobs}{$key}{strategy}{matrix}{include}) {
                for my $c (@$config) {
                    my $image = $c->{config}{image} or next;
                    ok $tags{$image}, "$image is used in $repo/$branch (by matrix include)";
                    $used{$image}{$branch} = 1;
                }
            }
        }
    }
}
for my $tag (keys %tags) {
    next if $used{$tag};
    fail "$tag is not used anywhere";
}

YAML::DumpFile('./tmp/used_images.yml', \%used);
note explain \%used;

done_testing;
