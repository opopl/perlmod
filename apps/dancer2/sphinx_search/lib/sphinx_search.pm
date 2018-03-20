package sphinx_search;
use Dancer2;

our $VERSION = '0.1';

get '/' => sub {
    template 'index' => { 'title' => 'sphinx_search' };
};

true;
