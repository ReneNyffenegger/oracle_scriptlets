create or replace package body zipper as -- {

--
--  Implementation by Anton Scheffer
--  See https://community.oracle.com/message/4510157#4510157
--

  function littleEndian(p_big in number, p_bytes in pls_integer := 4) return raw is -- {
  begin
    return utl_raw.substr(utl_raw.cast_from_binary_integer(p_big, utl_raw.little_endian), 1, p_bytes);
  end littleEndian; -- }

  procedure addFile(zip in out blob, filename in varchar2, content in blob) is -- {
    v_now   date;
    lz_blob blob;
    lz_len  integer;
    cn_len  integer;

    blob_temp blob;


  begin
    v_now   := sysdate;
    lz_blob := utl_compress.lz_compress(content);
    lz_len  := dbms_lob.getlength(lz_blob);
    cn_len  := dbms_lob.getlength(content);

    dbms_lob.append(
      zip,
      utl_raw.concat(
        hextoraw('504B0304'), -- Local file header signature
        hextoraw('1400'    ), -- version 2.0
        hextoraw('0000'    ), -- no General purpose bits
        hextoraw('0800'    ), -- deflate
        --
        -- File last modification time
        --
        littleEndian(
          to_number(to_char(v_now, 'ss'  ))    / 2 +
          to_number(to_char(v_now, 'mi'  )) *   32 + 
          to_number(to_char(v_now, 'hh24')) * 2048,
          2
        ),
        --
        -- File last modification date
        --
        littleEndian(
            to_number(to_char(v_now, 'dd'  ))        +
            to_number(to_char(v_now, 'mm'  ))  * 32  +
           (to_number(to_char(v_now, 'yyyy')) - 1980 ) * 512,
          2
        ), 
        --
        --
        --
        dbms_lob.substr(lz_blob, 4, lz_len - 7),      -- CRC-32
        littleEndian(lz_len - 18),                    -- compressed size
        littleEndian(dbms_lob.getlength(content)),    -- uncompressed size
        littleEndian(length(filename), 2),            -- File name length
        hextoraw('0000'),                             -- Extra field length
        utl_raw.cast_to_raw(filename)                 -- File name
      )
    );

    blob_temp := blob_wrapper.substr(lz_blob, lz_len-18, 11);
    dbms_lob.append(zip, blob_temp);
    dbms_lob.freetemporary(blob_temp);

  end addFile; -- }

  procedure finish(zip in out blob) -- {
  is
    v_cnt             pls_integer := 0;
    v_offs            integer;
    v_offs_dir_header integer;
    v_offs_end_header integer;
    v_comment raw(32767) := utl_raw.cast_to_raw('Implementation by Anton Scheffer');

  begin
    v_offs_dir_header := dbms_lob.getlength(zip);
    v_offs := dbms_lob.instr(zip, hextoraw('504B0304'), 1);

    while v_offs > 0 loop

      v_cnt := v_cnt + 1;
      dbms_lob.append(
        zip,
        utl_raw.concat(
          hextoraw('504B0102'),      -- Central directory file header signature
          hextoraw('1400'    ),      -- version 2.0
          dbms_lob.substr(zip, 26, v_offs + 4),
          hextoraw('0000'    ),      -- File comment length
          hextoraw('0000'    ),      -- Disk number where file starts
          hextoraw('0100'    ),      -- Internal file attributes
          hextoraw('2000B681'),      -- External file attributes
          littleEndian(v_offs - 1),  -- Relative offset of local file header
          --
          -- File name
          --
          dbms_lob.substr(
            zip,
            utl_raw.cast_to_binary_integer(
              dbms_lob.substr(zip, 2, v_offs + 26 ),
              utl_raw.little_endian
            ),
            v_offs + 30
           )
        )
      );
    
      v_offs := dbms_lob.instr(zip, hextoraw('504B0304'), v_offs + 32);

    end loop;

    v_offs_end_header := dbms_lob.getlength(zip);
    dbms_lob.append(
      zip,
      utl_raw.concat(
        hextoraw('504B0506'   ),                                -- End of central directory signature
        hextoraw('0000'       ),                                -- Number of this disk
        hextoraw('0000'       ),                                -- Disk where central directory starts
        littleEndian(v_cnt, 2 ),                                -- Number of central directory records on this disk
        littleEndian(v_cnt, 2 ),                                -- Total number of central directory records
        littleEndian(v_offs_end_header - v_offs_dir_header),    -- Size of central directory
        littleEndian(v_offs_dir_header),                        -- Relative offset of local file header
        littleEndian(nvl(utl_raw.length(v_comment), 0), 2),     -- ZIP file comment length
        v_comment
      )
    );

  end finish; -- }

end zipper; -- }
/
