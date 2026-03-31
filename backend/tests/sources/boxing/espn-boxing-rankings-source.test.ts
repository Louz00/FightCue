import test from "node:test";
import assert from "node:assert/strict";

import { parseEspnBoxingRankingsHtml } from "../../../src/sources/boxing/espn-boxing-rankings-source.js";

test("parseEspnBoxingRankingsHtml parses men's editorial divisions", () => {
  const html = `
    <p>For a list of the current champions in all weight classes, click here.</p>
    <h2>HEAVYWEIGHT (UNLIMITED)</h2>
    <aside class="inline inline-table">
      <table><tbody>
        <tr><td><div style="text-align:left"><h2>1. Oleksandr Usyk, <i>WBA, WBC and IBF champion</i></h2><br><b>Record:</b> 24-0, 15 KOs<br><b>Next:</b> TBA</div></td></tr>
        <tr><td><div style="text-align:left"><h2>2. Daniel Dubois</h2><br><b>Record:</b> 22-3, 21 KOs<br><b>Next:</b> TBA</div></td></tr>
      </tbody></table>
    </aside>
    <h2>WELTERWEIGHT (147 POUNDS)</h2>
    <aside class="inline inline-table">
      <table><tbody>
        <tr><td><div style="text-align:left"><h2>1. Jaron Ennis, <i>IBF champion</i></h2><br><b>Record:</b> 34-0, 30 KOs<br><b>Next:</b> TBA</div></td></tr>
      </tbody></table>
    </aside>
  `;

  const parsed = parseEspnBoxingRankingsHtml(html, "men");

  assert.equal(parsed.reportedItemCount, 2);
  assert.equal(parsed.items.length, 2);
  assert.equal(parsed.items[0]?.weightClass, "Heavyweight");
  assert.equal(parsed.items[0]?.entries[0]?.fighterName, "Oleksandr Usyk");
  assert.equal(parsed.items[0]?.entries[0]?.isChampion, true);
  assert.equal(parsed.items[1]?.weightClass, "Welterweight");
});

test("parseEspnBoxingRankingsHtml parses women's editorial divisions", () => {
  const html = `
    <p>For a list of the current champions in all weight classes, click here.</p>
    <h2>HEAVYWEIGHT (Over 175+ pounds)</h2>
    <aside class="inline inline-photo full"></aside>
    <h3>1. Claressa Shields</h3>
    <p><b>Record:</b> 17-0, 3 KO<br />
    <b>Next:</b> TBA</p>
    <hr>
    <h3>2. Danielle Perkins</h3>
    <p><b>Record:</b> 6-1, 3 KOs<br />
    <b>Next:</b> TBA</p>
    <h2>MIDDLEWEIGHT (160 pounds)</h2>
    <h3>1. Savannah Marshall</h3>
    <p><b>Record:</b> 14-1, 10 KOs<br />
    <b>Next:</b> TBA</p>
  `;

  const parsed = parseEspnBoxingRankingsHtml(html, "women");

  assert.equal(parsed.reportedItemCount, 2);
  assert.equal(parsed.items.length, 2);
  assert.equal(parsed.items[0]?.gender, "women");
  assert.equal(parsed.items[0]?.entries[0]?.fighterName, "Claressa Shields");
  assert.equal(parsed.items[0]?.entries[0]?.recordLabel, "17-0, 3 KO");
  assert.equal(parsed.items[1]?.weightClass, "Middleweight");
});
