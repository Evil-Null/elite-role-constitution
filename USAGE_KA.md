# მომხმარებლის გზამკვლევი — Elite Role Constitution

> ეს არის Kimi CLI 1.43+-ისთვის გაკეთებული "მკაცრი თანამშრომელი" — სისტემა, რომელიც აიძულებს AI-ს იმუშაოს დისციპლინირებულად: ჯერ გეგმა, შემდეგ შესრულება, შემდეგ შემოწმება. ეს დოკუმენტი გასაგებად აგიხსნით **როდის გამოიყენოთ, როგორ გამოიყენოთ და რა იცოდეთ მუშაობის დროს.**

---

## 1. ვისთვის არის ეს პროექტი

ეს პროექტი თქვენთვისაა, თუ:

- **გრძელვადიანი პროექტი გაქვთ** — ფიჩერი, რომელიც ერთ სესიაში ვერ მთავრდება, რეფაქტორი, რომელიც რამდენიმე დღე გრძელდება, ან არქიტექტურული ცვლილება, რომელიც ბევრ ფაილს ეხება.
- **მაღალი რისკის სამუშაო გაქვთ** — production code, migrations, security-relevant ცვლილებები, API contracts. ანუ ისეთი რამ, სადაც AI-ის "მე ვფიქრობ ალბათ ასე უნდა იყოს" ძვირი ჯდება.
- **AI-სგან მტკიცებულება გინდათ** — არ გინდათ რომ AI-მ "გაიხსენოს" ან "ივარაუდოს", გინდათ რომ **დააციტიროს** ფაილი:ხაზი ან command output.
- **იყენებთ Kimi CLI 1.43+-ს** — სხვა CLI-ებიც მუშაობს fallback რეჟიმში (იხ. `SYSTEM_PROMPT_INSTALL.md` §6), მაგრამ სრულ ღირებულებას მხოლოდ Kimi 1.43+ აძლევს.

**არ არის თქვენთვის, თუ:**

- ძალიან მარტივი კითხვებია ("რა არის 2+2", "ახსენი recursion ერთი წინადადებით"). ამისთვის overkill-ია — გამოიყენეთ `light effort` trigger ან საერთოდ Kimi-ის default agent.
- ერთჯერადი task-ია, რომელიც 5 წუთშიც ისე დასრულდება.
- File I/O არ გაქვთ ხელმისაწვდომი (read-only environment) — სისტემა memory ფაილებზე დგას.

---

## 2. რა მოგცემთ რეალურად

- **AI ვერ გამოიგონებს ფაქტს.** L1 (UNKNOWN=STOP) აიძულებს — ან მტკიცებულება არსებობს, ან AI გაჩერდება და გკითხავთ.
- **AI ვერ შეცვლის ფაილს თქვენი ნებართვის გარეშე.** L4 (PEV Loop) აიძულებს — ჯერ `[PLAN]` ცხადდება, შემდეგ `[APPROVED]`-ის შემდეგ ხდება რეალური ცვლილება.
- **AI ვერ ჩაწერს `.env` / `id_rsa` / `credentials`-ში.** Hook-ი ფიზიკურად ბლოკავს exit 2-ით.
- **Session-ის გადატვირთვის შემდეგ context გრძელდება.** Kimi-ის native `--continue` + ჩვენი `memory/RESUME.md` მუშაობენ ერთად.
- **`/compact`-ის შემდეგ task არ იკარგება.** Pre/PostCompact hook-ები ფიქსავენ მდგომარეობას `memory/COMPACT_STATE.md`-ში.
- **6 ფენიანი adversarial review** — Architect / Implementer / Risk Officer / QA / Final Arbiter / Red Team — ერთვება `challenge-grade` trigger-ით.

---

## 3. როდის გამოვიყენო (კონკრეტული სცენარები)

### 3.1 — ახალი ფიჩერი იწერება

```
plan only: REST endpoint /users/{id}/preferences-ის დამატება,
          JSON storage-ით, validation-ით და ტესტებით
```

AI მოგცემთ `[PLAN]`-ს acceptance criteria-თი, pre-mortem-ით, P×I რისკის ქულით. **არაფერი არ იცვლება ჯერჯერობით.** თქვენ შეგიძლიათ:

- თუ გეგმა მოგწონთ: `[APPROVED]`
- თუ რაიმეს შეცვლა გინდათ: "შეცვალე validation strict რეჟიმში, დანარჩენი ოკ", შემდეგ `[APPROVED]`

### 3.2 — Legacy კოდის რეფაქტორი

```
challenge-grade: გადახედე src/auth.py და მითხარი რეფაქტორის გეგმა
                 6 ლინზიდან, Red Team adversarial pass-ით
```

AI მოგცემთ დაახლოებით 800-სიტყვიან audit-ს, თითო ლინზაზე კონკრეტული მტკიცებულებით, Red Team-ის attack-ებით, anti-self-deception block-ით. ეს არის ყველაზე ღრმა გადახედვა.

### 3.3 — ეჭვი გაქვთ — დროა AI თვითონ შემოწმდეს

```
audit mode
```

ან:

```
/flow:audit-mode
```

AI გადახედავს ბოლო რამდენიმე პასუხს L1-L7-ის ფარგლებში, შეადგენს drift report-ს, ჩაწერს `memory/AUDIT_LOG.md`-ში.

### 3.4 — Session მთავრდება, ხვალ გააგრძელებთ

```
save state
```

AI ჩაწერს `memory/CONTEXT.md` + `memory/RESUME.md`-ში: სად ვართ, რა გადარჩა გასაკეთებელი, რა task იყო active. ხვალ რომ დაიწყოთ:

```
kimi --agent-file agent/elite.yaml --continue
```

და სრულდება — SessionStart hook წაიკითხავს memory ფაილებს და AI მიხვდება სად შეჩერდა.

### 3.5 — `/compact`-ი გჭირდებათ, token budget-ი იწურება

`/compact`-ის წერამდე AI **თვითონ** ჩაწერს `memory/COMPACT_STATE.md`-ში (PreCompact hook ახსენებს, AI ასრულებს). შემდეგ `/compact`-ის შემდეგ, PostCompact hook ამოწმებს — თუ snapshot გაქრა, **ფიზიკურად ვერ გააგრძელებთ მუშაობას** (exit 2). ეს არის L1-ის ფიზიკური განხორციელება.

### 3.6 — სწრაფი კითხვა გაქვთ, ცერემონია არ გინდათ

```
light effort
რა არის list comprehension?
```

ამ რეჟიმში L1-L7 ისევ მოქმედებს (AI ვერ ცრუობს), მაგრამ PEV ცერემონია გამოიტოვება. სწრაფი, კონცენტრირებული პასუხი მცირე task-ებისთვის.

### 3.7 — გეგმის დადასტურება ან უარყოფა

თუ AI-მ `[PLAN]` მოგცათ და მოგწონთ:

```
[APPROVED]
```

თუ მხოლოდ ერთ ფაზას აძლევთ უფლებას:

```
[APPROVED] Phase A only
```

თუ უარს ეუბნებით:

```
REJECT — Pre-mortem #2 არასწორია, validation უნდა იყოს strict
```

---

## 4. პირველი გაშვება (Setup)

თუ ცარიელი machine-ი გაქვთ:

```bash
# 1. რეპოს ჩამოწერა
git clone https://github.com/null0xxx/elite-role-constitution.git
cd elite-role-constitution

# 2. ერთი ბრძანებით install
bash install.sh --yes

# 3. Kimi-ის გაშვება elite agent-ით
kimi --agent-file agent/elite.yaml
```

`install.sh` ავტომატურად აკეთებს შემდეგს:

- ამოწმებს რომ Kimi 1.43+ დაყენებულია
- ხდის hook scripts-ს executable
- სიმბოლურად აკავშირებს skills-ს `~/.kimi/skills/`-ში (არჩევითი)
- ამატებს hooks-ს `~/.kimi/config.toml`-ში (backup-ით)
- ასრულებს live probe-ს დასადასტურებლად

### უფრო კომფორტული ცხოვრებისთვის — alias

დაამატეთ `~/.bashrc` ან `~/.zshrc`-ში:

```bash
elite() { kimi --agent-file "$HOME/Documents/projects/elite-role-constitution/agent/elite.yaml" "$@"; }
```

შემდეგ `source ~/.bashrc`. ახლა შეგიძლიათ:

```bash
elite                            # ინტერაქტიული სესია
elite --continue                 # წინა სესიის გაგრძელება
elite --print "შეასწავლე ეს PR"  # ერთჯერადი task
```

---

## 5. ყველა Trigger Phrase (ერთად)

### ტექსტური ფრაზები (ბუნებრივ ენაზე)

| ფრაზა | რას აკეთებს | როდის გამოიყენო |
|---|---|---|
| `plan only: <task>` | `[PLAN]` + P×I, არ ცვლის ფაილებს | სანამ AI რამეს იწყებს |
| `[APPROVED]` | PEV gate-ის გახსნა | plan მოგწონთ |
| `[APPROVED] <scope>` | მხოლოდ ნაწილის გახსნა | ნაწილობრივი approval |
| `REJECT — <reason>` | plan უარყოფა | plan არ მოგწონთ |
| `challenge-grade <subject>` | სრული 6-Lens audit, ≥800 სიტყვა | მაღალი რისკის task |
| `audit mode` | L1-L7-ის ფარგლებში drift check | როცა AI უცნაურად პასუხობს |
| `save state` | `CONTEXT.md` + `RESUME.md` ჩაწერა | session-ის ბოლოს |
| `resume` | 4 memory ფაილის წაკითხვა + summary | ახალი session-ის დასაწყისში |
| `rollup memory` | stale entries არქივში გადატანა | memory ფაილი cap-ს უახლოვდება |
| `light effort` (ან `quick check`) | მცირე ცერემონია | მარტივი task |
| `stop` (ან `escalate`) | მკაცრი pause, state ფიქსაცია | რაიმე გაიქცა, თქვენი გადაწყვეტილება გჭირდებათ |

### Slash commands (Kimi-native)

| ფრაზა | რას აკეთებს | როდის გამოიყენო |
|---|---|---|
| `/skill:elite-role` | სრული doctrine reference | AI უნდა გაიხსენოს წესები |
| `/flow:audit-mode` | Mermaid-driven audit ritual | ფორმალური audit |
| `/flow:challenge-grade` | Mermaid-driven 6-Lens review | ფორმალური challenge |
| `/flow:save-state` | Mermaid-driven memory autosave | სუფთა save-state |

---

## 6. რას ცვლის სისტემა ფონზე (Hooks)

ეს ხდება ავტომატურად, თქვენი ჩარევის გარეშე:

- **`.env`-ის რედაქტირების მცდელობა** → PreToolUse hook ბლოკავს (`exit 2` + სტდერრ შეტყობინება). თუ ნამდვილად გჭირდებათ, `.env.example` შეცვალეთ.
- **`bash`-ით `cat secrets > .env`** → pre-shell.sh hook ბლოკავს (იცის `>`, `>>`, `tee`, `cp`, `mv`, `sed -i` targets).
- **API key შემთხვევით კოდში** → secret-pattern scan ბლოკავს AWS, OpenAI, Anthropic, GitHub PAT, Slack, Stripe, ნებისმიერი PEM private-key header.
- **`/compact`-ის შემდეგ snapshot გაქრა** → PostCompact ბლოკავს მუშაობას სანამ `COMPACT_STATE.md` არ ჩაიწერება.
- **AI-მ L6 (3-ways-wrong) დაივიწყა** → Stop hook ახსენებს რომ self-deception check სავალდებულოა.
- **STOP-level escalation (P×I ≥ 19)** → Notification hook აგზავნის desktop alert-ს (`notify-send` Linux-ზე, `osascript` macOS-ზე).

ეს ყველაფერი თქვენი ჩარევის გარეშე მუშაობს.

---

## 7. რა იცოდეთ მუშაობის დროს

### AI რომ "ჯიუტი" გახდეს — გასაგებია, ეს ფიჩერია

თუ თქვენ ცდილობთ რომ AI-მ "ცარიელად მოახდინოს" რაიმე ცვლილება (`.env`-ში ჩაწეროს key, plan-ის გარეშე გააკეთოს refactor) და ის უარს ამბობს — სისტემა მუშაობს. ეს არ არის bug. ეს არის L7 (Absolute Contract) მოქმედებაში.

თუ ნამდვილად გჭირდებათ override-ი, **ცხადად მიუთითეთ**:

```
ვიცი რომ pre-tool-use ბლოკავს, მინდა რომ ეს ცვლილება მაინც გავაკეთო,
რადგან [მიზეზი]. დააფიქსირე ASSUMPTIONS.md-ში და გააგრძელე.
```

AI ჯერ ჩაწერს ASSUMPTIONS.md-ში, შემდეგ შესთავაზებს გვერდით გზას (მაგ. `.env.example`-ის შეცვლა).

### "AI ცარიელად დაიწყო ცარიელად" — შესაძლო მიზეზები

- **Hooks არ არის wired** — შეამოწმეთ: `grep elite-role ~/.kimi/config.toml`. თუ ცარიელია, `bash install.sh --hooks-only` გაუშვით.
- **Skill-ი არ ჩაიტვირთა** — Kimi უნდა გაუშვათ რეპოს root-ში. შეამოწმეთ: `ls .kimi/skills/`.
- **Agent file არ მიუთითებთ** — `--agent-file agent/elite.yaml` სავალდებულოა, ცარიელი `kimi` default agent-ით გაიხსნება.

### Memory ფაილების მართვა

Memory ფაილებს ხელით ნუ შეცვლით default-ად. სისტემა მათ თვითონ მართავს:

- `CONTEXT.md` — AI ფიქსავს active task-ს
- `RESUME.md` — session-ის ბოლოს ჩაიწერება
- `ASSUMPTIONS.md` — declared assumptions
- `DECISIONS.md` — significant choices
- `AUDIT_LOG.md` — task history

ცვლილებები საჭიროა მხოლოდ მაშინ, თუ ხელით გინდათ task-ის "გადატვირთვა". ამ შემთხვევაში `memory/CONTEXT.md`-ის ცარიელად დატოვება და `save state`-ის წერა საკმარისია.

### თუ რაიმე გატყდა

```bash
bash SYSTEM_INTEGRITY_CHECK.sh
```

თუ `10/10 PASS` ბრუნდება, რეპო ჯანმრთელია. თუ რომელიმე check ჩავარდა, შეტყობინებას წაიკითხეთ — სისტემა გასაგებად გეტყვით რა მოხდა (მაგ. "memory/ASSUMPTIONS.md: 52 lines > 50 max").

---

## 8. რას **არ** გვაძლევს ეს სისტემა

გულახდილად:

- **არ ცვლის AI-ის ცოდნას.** თუ AI-ს არ ეცოდინება Rust-ი, doctrine-ი მას Rust-ის ექსპერტად ვერ აქცევს.
- **არ არის bug-free guarantee.** L1-L7 ამცირებს ცდენების ალბათობას, არ აქრობს მთლიანად.
- **არ ცვლის human review-ს.** Production-ში გასაშვებამდე **ცოცხალი ადამიანი უნდა გადახედოს**. სისტემა მხოლოდ AI-ის ეტაპს აუმჯობესებს.
- **არ არის "set it and forget it".** ცარიელად დარჩა Phase B.1.b (7-დღიანი stress test) — long-term behavioral drift ემპირიულად არ არის დადასტურებული. იყავით ფხიზლად.
- **Hook-ები Beta-ში არიან Kimi-ის თვალით.** Configuration schema შესაძლოა შეიცვალოს მომავალ ვერსიებში — `KIMI_PROTOCOL.md` §C.2 ცხადად ამბობს.

---

## 9. ბოლო რჩევები — სუფთა workflow

1. **დღის დასაწყისი:** `elite --continue` (ან `kimi --agent-file agent/elite.yaml --continue`). AI თვითონ წაიკითხავს RESUME-ს და გაგრძელდება იქედან სადაც ეჩერდა.
2. **ახალი task-ის წინ:** `plan only: <task>`. ჯერ გეგმა ნახეთ, შემდეგ `[APPROVED]`.
3. **დიდი ცვლილების შემდეგ:** `challenge-grade ეს PR გადახედე`. AI გადახედავს 6 ლინზიდან.
4. **დღის ბოლოს:** `save state`. ხვალისთვის სუფთა checkpoint.
5. **მუშაობის დროს:** ნუ ეცდებით override-ი — სისტემა გვერდით გზას შემოგთავაზებთ.
6. **ეჭვის შემთხვევაში:** `bash SYSTEM_INTEGRITY_CHECK.sh` რეპოს ჯანმრთელობას აჩვენებს.

---

## 10. ერთ წინადადებად

> ეს არის სისტემა AI-სთვის, რომელიც აიძულებს მას იყოს **მკაცრი, ციტირებადი და დისციპლინირებული** პარტნიორი — ნაცვლად "ცარიელად კარგი" გენერატორისა, რომელიც კარგი first-turn-ში და ცუდი fiftieth-ში.

დეტალური დოკუმენტაცია: `01_ELITE_ROLE.md` (კონსტიტუცია), `KIMI_PROTOCOL.md` (deployment protocol), `IMPROVEMENT_PLAN.md` (post-audit roadmap), `INDEPENDENT_VALIDATION.md` (12 checks for independent verifiers).

გაუმართლოს მუშაობას.
