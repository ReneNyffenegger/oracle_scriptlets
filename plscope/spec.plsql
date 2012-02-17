create or replace package plscope as

    subtype  signature_   is varchar2(32);

    type     signature_t_ is table of signature_;

    procedure fill_callable(owner_ in varchar2, delete_existing in boolean);

    procedure fill_call    (owner_ in varchar2, delete_existing in boolean);

    procedure print_upwards_graph (sig signature_, format in varchar2);

    procedure print_dot_graph;
    
    function  who_calls(sig_called signature_) return signature_t_;

    procedure gather_identifiers;

end plscope;
/
