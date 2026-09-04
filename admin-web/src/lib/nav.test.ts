import { describe, expect, it } from "vitest";
import { NAV_ITEMS } from "./nav";

describe("NAV_ITEMS", () => {
  it("matches the 14 sections from the brief's Admin Dashboard Navigation", () => {
    expect(NAV_ITEMS).toHaveLength(14);
  });

  it("has a unique href per item", () => {
    const hrefs = NAV_ITEMS.map((item) => item.href);
    expect(new Set(hrefs).size).toBe(hrefs.length);
  });

  it("starts with the Dashboard link pointing at the root", () => {
    expect(NAV_ITEMS[0]).toEqual({ label: "Dashboard", href: "/" });
  });
});
