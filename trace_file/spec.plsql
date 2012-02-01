create or replace package trace_file

/* 
   Package trace_file (spec.plsql and body.plsql)

   Copyright (C) René Nyffenegger

   This source code is provided 'as-is', without any express or implied
   warranty. In no event will the author be held liable for any damages
   arising from the use of this software.

   Permission is granted to anyone to use this software for any purpose,
   including commercial applications, and to alter it and redistribute it
   freely, subject to the following restrictions:

   1. The origin of this source code must not be misrepresented; you must not
      claim that you wrote the original source code. If you use this source code
      in a product, an acknowledgment in the product documentation would be
      appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
      misrepresented as being the original source code.

   3. This notice may not be removed or altered from any source distribution.

   René Nyffenegger rene.nyffenegger@adp-gmbh.ch

*/

  authid current_user
as

  max_line_len constant number := 32767;
  cur_line#             number         ; 

  procedure start_   (sql_stmt in varchar2, remove_file in boolean := true);
  procedure stop__   (sql_stmt in varchar2);

  function  next_line(line    out varchar2) return boolean;

  ----

  procedure dump_block(file_no in number, block_no in number);
  procedure dump_block(row_id  in rowid);

end trace_file;
/
