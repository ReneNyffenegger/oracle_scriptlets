create or replace package calendar as

  function EasterSunday           (yr in number) return date;
  function CarnivalMonday         (yr in number) return date;
  function MardiGras              (yr in number) return date;
  function AshWednesday           (yr in number) return date;
  function PalmSunday             (yr in number) return date;
  function EasterFriday           (yr in number) return date;
  function EasterSaturday         (yr in number) return date;
  function EasterMonday           (yr in number) return date;
  function AscensionOfChrist      (yr in number) return date;
  function Whitsunday             (yr in number) return date;
  function Whitmonday             (yr in number) return date;
  function FeastofCorpusChristi   (yr in number) return date;

end;
/
