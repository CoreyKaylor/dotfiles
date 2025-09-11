return {
  'tpope/vim-abolish',
  keys = {
    { "crs", desc = "Convert to snake_case" },
    { "crm", desc = "Convert to MixedCase" },
    { "crc", desc = "Convert to camelCase" },
    { "cru", desc = "Convert to UPPER_CASE" },
    { "cr-", desc = "Convert to dash-case" },
    { "cr.", desc = "Convert to dot.case" },
    { "cr<space>", desc = "Convert to space case" },
    { "crt", desc = "Convert to Title Case" },
  },
  cmd = {
    "S",
    "Abolish",
    "Subvert",
  },
  
  config = function()
    -- vim-abolish is primarily configured through its built-in mappings
    -- The plugin automatically provides:
    -- crs (snake_case), crm (MixedCase), crc (camelCase), cru (UPPER_CASE)
    -- cr- (dash-case), cr. (dot.case), cr<space> (space case), crt (Title Case)
    
    -- Additional abbreviations can be defined here if needed
    -- Example: vim.cmd([[Abolish {despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or} {despe,sepa}rat{}]])
    
    -- The :S command provides smart substitution with case preservation
    -- Example: :S/facilit{y,ies}/building{,s}/g
    
    -- Common programming abbreviations
    vim.cmd([[Abolish teh the]])
    vim.cmd([[Abolish seperate separate]])
    vim.cmd([[Abolish definately definitely]])
    vim.cmd([[Abolish recieve receive]])
    vim.cmd([[Abolish occured occurred]])
    vim.cmd([[Abolish occuring occurring]])
    vim.cmd([[Abolish waht what]])
    vim.cmd([[Abolish tehn then]])
    
    -- Programming-specific abbreviations
    vim.cmd([[Abolish lenght length]])
    vim.cmd([[Abolish widht width]])
    vim.cmd([[Abolish heigth height]])
    vim.cmd([[Abolish rigth right]])
    vim.cmd([[Abolish retrun return]])
    vim.cmd([[Abolish fucntion function]])
    vim.cmd([[Abolish calback callback]])
    vim.cmd([[Abolish responce response]])
    
    -- Create a command for easy access to case coercion help
    vim.api.nvim_create_user_command('CaseHelp', function()
      vim.notify([[
Case Conversion Commands (vim-abolish):
  crs - snake_case
  crm - MixedCase (PascalCase)
  crc - camelCase
  cru - UPPER_CASE
  cr- - dash-case
  cr. - dot.case
  cr<space> - space case
  crt - Title Case

Smart Substitution:
  :S/old/new/g - Smart substitution with case preservation
  :S/facilit{y,ies}/building{,s}/g - Handle variants

Place cursor on word and use case commands to convert.
]], vim.log.levels.INFO, { title = "Abolish Help" })
    end, { desc = 'Show case conversion help' })
  end,
}